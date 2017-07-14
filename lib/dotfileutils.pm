#
# dotfileutils - Utility functions for dotfile preprocessing
#
# Copyright (c) 2013 nandhp <nandhp@gmail.com>
# License: Simplified (2-clause) BSD, see COPYING.BSD

package dotfileutils;

BEGIN{ Qupp->import }

use Sys::Hostname;
use File::Basename;
use File::Spec;
use File::Find;

use warnings;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(run_parts $HOSTNAME $HOME);

# For relative pathnames
my @caller = caller();
my $origfile = $caller[1];

# Add subdirectories to the include path
# push @PATH, <*/>;
find({wanted => sub { push @PATH, $_ if -d $_ and $_ !~ /\/\./ },
      no_chdir => 1}, '.');

# Include all files matching $glob in the include path.
# For example, run_parts('*.bashrc');
sub run_parts {
    my ($glob, $commentchar, $func) = @_;
    $func ||= \&include;
    printf("\n%s (begin run_parts %s)\n", $commentchar, $glob) if $commentchar;
    foreach my $file ( sort basename_sort path_glob $glob ) {
        next if $file =~ /\~$/; # Editor backup files
        printf("\n%s %s\n\n", $commentchar,
               File::Spec->abs2rel($file, dirname($origfile))) if $commentchar;
        $func->($file);
    }
    printf("\n%s (end run_parts %s)\n", $commentchar, $glob) if $commentchar;
}

# Some useful variables
(our $HOSTNAME = hostname) =~ s/\..*//;
our $HOME = $ENV{HOME};

1;
