package dotfileutils;

BEGIN{ Qupp->import }

use Sys::Hostname;
use File::Basename;
use File::Spec;

use warnings;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(run_parts $HOSTNAME);

# For relative pathnames
my @caller = caller();
my $origfile = $caller[1];

# Add subdirectories to the include path
push @PATH, <*/>;

# Include all files matching $glob in the include path.
# For example, run_parts('*.bashrc');
sub run_parts {
    my ($glob, $commentchar) = @_;
    printf("\n%s (begin run_parts %s)\n", $commentchar, $glob) if $commentchar;
    foreach my $file ( sort basename_sort path_glob $glob ) {
        printf("\n%s %s\n\n", $commentchar,
               File::Spec->abs2rel($file, dirname($origfile))) if $commentchar;
        include $file;
    }
    printf("\n%s (end run_parts %s)\n", $commentchar, $glob) if $commentchar;
}

# Some useful variables
(our $HOSTNAME = hostname) =~ s/\..*//;

1;
