#!/usr/bin/perl
#
# qupp - QUPP: Untitled Perl Preprocessor
# Copyright (C) 2013 nandhp <nandhp@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl 5.18.1.
#
# This program is distributed in the hope that it will be useful, but
# without any warranty; without even the implied warranty of
# merchantability or fitness for a particular purpose.
#

=head1 NAME

qupp - QUPP: Untitled Perl Preprocessor

=head1 SYNOPSIS

B<qupp> [I<options>] [I<scriptfile>]

=head1 DESCRIPTION

QUPP is a Perl-based file preprocessor.
It's similar to PHP (a hypertext preprocessor), but built out of Perl.

=cut

package Qupp;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = ();               # Filled in below

use Getopt::Long;
use Pod::Usage;
use File::Spec;
use File::Basename;
use File::Glob 'bsd_glob';

use warnings;
use strict;

=head1 OPTIONS

=over

=item B<--verbose>, B<--debug>

Enable verbose Perl code.
This is the default.

=item B<--stop>, B<-S>

Output the generated Perl code instead of running it.

=item B<--use> I<module>, B<-M>

Use Perl module I<module>.

=item B<--include> I<directory>, B<-I>

Add I<directory> to the beginning of C<@PATH> (and by extension, C<@INC>).

=back

=cut

# Initialize shared global variables
our @PATH = ('','.');           # Empty string = same dir as file
our @FILE = ();                 # Stack of included files
our @MODULES = ('-warnings', '-strict'); # Modules to load
my @REALINC = @INC;
push @EXPORT, '@PATH';          # Export @PATH

# Initialize private global variables
my $DEBUG = 1;                  # Write more verbose Perl code
my @texts = ();                 # List of text literals
my $texts_base = 100;           # Origin for index provided to _print_text

# Parse command-line
my $stopearly = 0;              # Only output generated Perl code
GetOptions('verbose|debug' => \$DEBUG, 'stop|S' => \$stopearly,
           'include|I=s' => sub { unshift @PATH, $_[1] },
           'use|M=s' => sub { push @MODULES, $_[1] },
           help => sub { pod2usage(1) }) or pod2usage(2);

=head1 LANGUAGE

=head2 Basic Syntax

A QUPP script is treated as opaque data that is copied to STDOUT, except between opening and closing tags (C<E<lt>?> and C<?E<gt>>, respectively).
Data between within the tags is interpreted as Perl code.
If the end tag is omitted, the Perl code section will continue until end of file.

A variation C<E<lt>?=> on the opening tag is available that prints the return value of the code.
C<E<lt>?= $x ?E<gt>> is equivalent to C<E<lt>? print $x ?E<gt>>.

=cut

# Convert an input file to Perl code
sub perlify {
    my ($data, $filename) = @_;
    $filename =~ s/[^\x20-\x7e]|"/?/g;
    my $perl = "\n;{\npackage main;BEGIN { Qupp->import };\n";
    foreach ( @MODULES ) {
        m/^(-?)(.+)/;
        my $prefix = $1 ? 'no' : 'use';
        my $module = $2;
        $perl .= "$prefix $module;\n";
    }

    # Convert a text literal to a brief comment for clarifying verbose output
    sub commentify {
        my ($str) = @_;
        my $max = 55;
        #$str =~ s/^\s*|\s*\n.*$//sg;
        #$str =~ s/\s/ /g;
        $str =~ s/([^\x20-\x7e])/sprintf('<%02X>',ord($1))/ge;
        #$str =~ s/ +$//;
        $str = substr($str, 0, $max-15).'<...>'.substr($str,-10)
            if length($str) > $max;
        return ' #:' . $str;
    }

    my $lineno = 1;
    while ( $data =~ m/<\?(?!xml)(=?) *(.*?[\r\n]*) *(?:\?>|$)|(.+?[\r\n]*)(?=(?:$|<\?))/gs ) {
        my ($isprint, $iscode, $text) = ($1, defined($2), $2||$3);
        die if $2 and $3;       # We can't have both at once!
        $perl .= "\n" if $DEBUG and $perl !~ m/\n$/;
        $perl .= "#line $lineno \"$filename\"\n" if $DEBUG;
        if ( $iscode ) {
            # Perl code section
            if ( $isprint ) {
                $text = "print $text";
            }
            $perl .= $text;
        }
        else {
            # Text literal section
            next if $text eq '';
            push @texts, $text;
            # Use 1-origin to catch errors that turn into a 0.
            my $num = $#texts+$texts_base;
            # Append to the generated Perl code
            $perl .= ";{_print_text($num)};";
            if ( $DEBUG ) {
                my $comment = $DEBUG ? commentify($text) : '';
                $perl .= "$comment\n";
            }
        }
        # Update line number
        $lineno++ while $DEBUG and $text =~ m/\n/g;
    }
    $perl .= "\n};\n";
    return $perl;
}

# Report an error message. Indent error messages from nested inclusions.
sub report_error {
    my ($err) = @_;
    $err =~ s/^/  /mg;
    $err =~ s/\s*$//g;
    die "Error from $FILE[-1][1]:\n$err\n";
}

# Evaluate Perl code using plain eval.
sub interpret {
    # Don't define variables; we'd like to keep the eval environment cleaner.
    # my ($perl, $file) = @_;
    push @FILE, [File::Spec->rel2abs($_[1]), $_[1]];
    local @INC = (get_path(), @REALINC);
    eval(shift(@_));
    report_error($@) if $@;
    pop @FILE;
}

# Evaluate file from the command-line
sub main {
    warn "Multiple files on the command-line is not well-supported."
        if @ARGV > 1;
    my $data = join '', <>;
    my $file = $ARGV;
    close ARGV;
    my $perl = perlify($data, $file);
    if ( $stopearly ) {
        print $perl;
        exit 0;
    }
    interpret($perl, $file);
    exit 0;
}

sub get_path {
    my @dirs = ();
    foreach ( @PATH ) {
        my $dir = $_ ? $_ : dirname($FILE[-1][0]);
        push @dirs, $dir;
    }
    return @dirs;
}

###############################################################################
# Functions available to QUPP scripts

=head2 Functions

Several functions are available to QUPP scripts.

=over

=cut

=item _print_text ID

Print a text literal from the input file.
For internal use by the compiler.

=cut

sub _print_text {
    my $num = int($_[0]);
    # Verify the number is in the correct range
    die "_print_text: $num out of range"
        unless $num >= $texts_base and $num <= $#texts+$texts_base;
    print $texts[$num-$texts_base];
}
push @EXPORT, '_print_text';

=item include FILES

Include another QUPP script (or several of them) at runtime.
The filenames will be searched for relative to each directory in C<@PATH>.

=cut
sub include {
    my @files = @_;
  INCFILE:
    foreach my $filename ( @files ) {
        foreach my $dir ( get_path() ) {
            my $file = File::Spec->rel2abs($filename, $dir);
            next unless -e $file;
            open F, '<', $file or die "Can't open $file: $!";
            my $data = join '', <F>;
            close F;
            interpret(perlify($data, $file), $file);
            next INCFILE;
        }
        die "Couldn't find $filename in \@PATH\n";
    }
}
push @EXPORT, 'include';

=item path_glob GLOBS

Search the directories in C<@PATH> for files matching each glob.
Returns the matched files.

=cut
sub path_glob {
    my @globs = @_;
    my %files = ();
    foreach my $filename ( @globs ) {
        foreach my $dir ( get_path() ) {
            $dir =~ s/([\\\[\]{}*?~])/\\$1/g;
            my $file = File::Spec->rel2abs($filename, $dir);
            $files{$_} = 1 foreach bsd_glob $file;
        }
    }
    return keys %files;
}
push @EXPORT, 'path_glob';

=item basename_sort $a $b

Comparison subroutine for L<sort|perlfunc/sort> that performs a comparison on the basenames of each path.
Use in conjunction with include and path_glob to implement run-parts:

    include sort basename_sort path_glob "*.bashrc"

=cut
sub basename_sort($$) {         # Prototype required for use as sort comparator
    my ($a, $b) = @_;
    return basename($a) cmp basename($b);
}
push @EXPORT, 'basename_sort';

# FIXME: Implement run_parts (glob?), include path (include and do?), etc.
# Try some dotfiles with it, build dotfile infrastructure around it.
# Reuse existing dotfile manager?

=back

=head1 EXAMPLES

Section reserved for future expansion

=head1 BUGS

The "language parser" is implemented as a single regular expression, so bugs are likely to be encountered when transitioning between text literal sections and Perl code sections.

=head1 AUTHOR

nandhp <nandhp@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2013 nandhp <nandhp@gmail.com>

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl 5.18.1.

This program is distributed in the hope that it will be useful, but
without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=head1 SEE ALSO

L<perl(1)>

=cut

main();

1;
