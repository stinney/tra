#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;

use lib "$ENV{'ORACC_BUILDS'}/lib";

use Getopt::Long;

GetOptions(
    );

my @l = (<>);
my $lnum = 0;
for (my $i = 0; $i < $#l; ++$i) {
    if ($l[$i] =~ /^\d\S*?\.\s/) {
	$lnum = $i;
    } elsif ($l[$i] =~ /line-id=(.*?)$/) {
	my $enum = $1;
	$l[$lnum] =~ s/^\S+\.\s/$enum. /;
    }
}

print @l;

1;

################################################################################

