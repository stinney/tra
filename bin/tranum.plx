#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;

use lib "$ENV{'ORACC_BUILDS'}/lib";

use Getopt::Long;

GetOptions(
    );

my @tr = grep(!/^\s*$/, (<>));

my $paras = 0;
for (my $i = 0; $i <= $#tr; ++$i) {
    if ($tr[$i] =~ s/^\@\((.*?)\)\s*//) {
	my $l = $1;
	if ($l =~ /^(.*?)\s+-\s+(.*?)$/) {
	    my $first = $1;
	    my $last = $2;
	    my $count = $2 - $1;
	    for (my $j = 0; $j <= $count; ++$j) {
		print "$first. $tr[$i]";
		++$first;
		++$i;
	    }
	    --$first;
	    --$i;
	    if ("$first" ne "$last") {
		warn "$i: $first != $last\n";
	    }
	} else {
	    print "$l. $tr[$i]";
	}
    }
}

1;

################################################################################

