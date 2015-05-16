#!/usr/bin/perl
#
# install.pl - Compile and install dotfiles
#
# Copyright (c) 2013 nandhp <nandhp@gmail.com>
# License: Simplified (2-clause) BSD, see COPYING.BSD

use File::Find;
use File::Spec;
use File::Basename;
use Text::ParseWords;
use Data::Dumper;
use warnings;
use strict;

my $COMMENTS = "#;!%'";
my $BASE = File::Spec->rel2abs(File::Spec->curdir());
my $LIBDIR = File::Spec->rel2abs('lib');
my $QUPP = File::Spec->rel2abs('qupp.pl', $LIBDIR);
my $BUILD = File::Spec->rel2abs('.build', $BASE);
my $INSTALLFILE = File::Spec->rel2abs('.install', $BUILD);
my $HOME = $ENV{HOME};

die "$HOME does not exist" unless -d $HOME;
mkdir($BUILD, 0700) or die "mkdir $BUILD: $!" unless -d $BUILD;
chmod(0700, $BUILD) or die "chmod $BUILD: $!";

my $APP = $0;
foreach ( @ARGV ? @ARGV : qw(help) ) {
    if ( $_ eq '--as-make' ) {
        $APP = 'make';
    }
    elsif ( $_ eq 'build' ) {
        build();
        print STDERR "OK, now try $APP diff or $APP install\n";
    }
    elsif ( $_ eq 'diff' ) {
        diff();
        print STDERR "OK, now try $APP noact or $APP install\n";
    }
    elsif ( $_ eq 'noact' ) {
        install(0);
        print STDERR "OK, now try $APP install\n";
    }
    elsif ( $_ eq 'install' ) {
        install(1);
        print STDERR "OK, installation complete\n";
    }
    else {
        die "Usage: $APP <build|diff|noact|install>\n";
    }
}

sub build {
    my @diffs = ();
    my @dirs = ();
    my @files = ();

    my $process_file = sub {
        my $path = $File::Find::name;
        my $origfile = File::Spec->abs2rel($path, $BASE);
        # Determine if we should process the file
        return unless -f $path;
        if ( $origfile =~ /(.*)(^|\/)\.install$/ and $1 !~ m/(^|\/)\./ ) {
            # FIXME: Replace with ?run, implemented below
            push @dirs, ['sh', '-e', '-c',
                         'cd "$(dirname "$1")"; ./"$(basename "$1")"', '-',
                         $origfile];
            push @diffs, ['i', $origfile];
            return;
        }
        return if $origfile =~ /(^|\/)[#.]|(\.pm|~)$/;
        open F, '<', $path or die "open $path: $!";
        my $line = <F>;
        $line = <F> while $line and $line =~ m/^#!|^<(\?xml|!DOCTYPE|!--)/i;
        close F;
        return if !$line or $line !~ m/^[$COMMENTS]+\?/;
        (my $file = $origfile) =~ s/[^-+_a-zA-Z0-9.,]/_/g;

        # Process the file
        my $outfile = "$BUILD/$file";
        open F, '-|', $QUPP, '-I', $LIBDIR, '-M', 'dotfileutils',
             $path or die "qupp $path: $!";
        open OUT, '>', $outfile or die "open $outfile: $!";
        my $cmdno = 0;
      LINE:
        while (<F>) {
            unless ( m/^([$COMMENTS]{1,2})\?\s*(.*?)\s*$/ ) {
                print OUT;
                next;
            }
            my ($commentchar, $commandline) = ($1, $2);
            $commandline =~ s/-\*-.*-\*-//; # Emacs mode configuration
            if ( $commandline =~ m/^\s*quiet/ ) {
                $cmdno++;
                next;
            }
            if ( $cmdno == 0 ) {
                my $now = localtime;
                print OUT "$commentchar $_\n" foreach
                    ('DO NOT EDIT THIS FILE',
                     "Autogenerated from .../$origfile at $now")
            }
            $cmdno++;
            my @command = shellwords($commandline);
            next unless @command;
            my $cmd = $command[0];
            if ( $cmd eq 'install' ) {
                # Handle an install command; is it for a directory or
                # do we need to insert the source filename?

                # Tilde (and wildcard) expansion on destination
                push @command, do_glob(pop @command);

                # FIXME: Requires no space between option and argument (-m0700)
                # FIXME: Requires all options before nonoptions
                for ( my $i = 1; $i < @command; $i++ ) {
                    if ( $command[$i] =~ /^-[a-z]*d|^--directory$/ ) {
                        push @dirs, \@command;
                        push @diffs, ['d', $command[-1]];
                        next LINE;
                    }
                    elsif ( $command[$i] eq '--' ) {
                        splice(@command, $i, 1);
                        redo;
                    }
                }
                splice(@command, 1, 0, '-m0644', '-b');
                splice(@command, @command-1, 0, '--', $outfile);
                push @diffs, ['f', $command[-1], $outfile];
                push @files, \@command;
                next LINE;
            }
            elsif ( $cmd eq 'ln' ) {
                # Sometimes we need symlinks, too
                my @newcmd = ('ln', '-f', '--');
                my $ok = 0;
                my $last = undef;
                foreach ( @command[1..$#command] ) {
                    if ( m/^-s/ ) { $newcmd[1] .= 's'; next }
                    $ok=99 if m/^-/;
                    push @newcmd, do_glob($_, undef);
                    $last = do_glob($_);
                    $ok++;
                }
                defined($last) or $ok = 99;
                $newcmd[-1] = $last;
                $ok = 99 if $newcmd[1] ne '-fs';
                die "$path: ln: Usage: ln -s <target> <linkname>; " .
                    "got @newcmd" unless $ok == 2;
                die "$path: ln: Won't overwrite non-symlink $newcmd[-1]"
                    if -e $newcmd[-1] and !-l $newcmd[-1];
                push @files, \@newcmd;
                push @diffs, ['l', $newcmd[-1], $newcmd[-2]];
            }
            # FIXME: better way to run one-off commands
            elsif ( $cmd eq 'shell' ) {
                (my $shellcmd = $commandline) =~ s/^\s*shell\s+//i;
                push @files, ['sh', '-c', $shellcmd, '', $origfile, $outfile];
                push @diffs, ['i', $origfile, "Run $shellcmd"];
            }
            elsif ( $cmd eq 'run' ) {
                chmod 0700, $outfile or die "chmod $outfile: $!";
                push @dirs, ['sh', '-e', '-c',
                             'cd "$(dirname "$1")"; "$2"', '-',
                             $origfile, $outfile];
                push @diffs, ['i', $outfile];
            }
            else {
                warn "$path: $cmd not recognized.\n";
            }
        }
        close OUT or die "close $outfile: $!";
        close F or die "qupp $path failed: " . ($!||"Unreported error");
    };

    find({wanted => $process_file, no_chdir => 1}, $BASE);
    open F, '>', $INSTALLFILE or die "Can't write installfile: $!";
    print F Data::Dumper->Dump([\@dirs,\@files,\@diffs],
                               [qw(*dirs *files *diffs)]);
    close F;
}

sub read_installfile {
    open F, '<', $INSTALLFILE or die "Can't read installfile: $!";
    my $buf = join('', <F>);
    close F;
    return $buf;
}

sub diff {
    my (@dirs, @files, @diffs); eval read_installfile();
    for my $info ( @diffs ) {
        my ($type, @data) = @$info;
        my $rc = 0;
        print "=== $data[0]\n";
        if ( $type eq 'f' ) {
            if ( -e $data[0] ) {
                system('diff', "-I^[$COMMENTS]* Autogenerated from ",
                       '-u', '--', @data);
            }
            else {
                print "Create file $data[0]\n";
            }
        }
        elsif ( $type eq 'l' ) {
            if ( -l $data[0] ) {
                my $old = readlink $data[0];
                if ( $old ne $data[1] ) {
                    print "Change symlink from $old to $data[1]\n";
                }
            }
            elsif ( !-e $data[0] ) {
                print "Create symlink to $data[1]\n";
            }
            else {
                die "$data[1]: ln: Won't overwrite non-symlink $data[0]";
            }
        }
        elsif ( $type eq 'd' ) {
            if ( -d $data[0] ) { }
            elsif ( -e $data[0] ) {
                print "Replace existing file with a directory\n";
            }
            else {
                print "Create directory\n";
            }
        }
        elsif ( $type eq 'i' ) {
            print $data[1] ? "$data[1]\n" : "Run script $data[0]\n";
        }
        else {
            die "Unknown diff type $type";
        }
    }
}
sub install {
    my ($doit) = @_;
    my (@dirs, @files, @diffs); eval read_installfile();
    for my $cmd ( @dirs, @files ) {
        print join(' ', @$cmd), "\n";
        next unless $doit;
        my $rc = system(@$cmd);
        $rc == 0 or die "@$cmd: exit status $rc (-1=>$!)";
    }
}

sub do_glob {
    my ($file, $base) = @_;
    $base = $HOME if @_ < 2;
    $file =~ s/^~/$HOME/;
    return defined($base) ? File::Spec->rel2abs($file, $base) : $file;
}
