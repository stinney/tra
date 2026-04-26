#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;

use lib "$ENV{'ORACC_BUILDS'}/lib";

use Getopt::Long;

GetOptions(
    );

my %qe = (); my @qe = `cat nqe.tsv`; chomp @qe;
foreach (@qe) { my($q,$e) = split(/\t/,$_); $qe{$e} = $q; }

while (<>) {
    chomp;
    if (/\t/) {
	my @f = split(/\t/, $_);
	my $q = '';
	foreach my $f (@f) {
	    if ($qe{$f}) {
		$q = $qe{$f};
		last;
	    }
	}
	if ($q) {
	    print join("\t", $q, @f), "\n";
	} else {
	    warn "$_ not matched to qe tab\n";
	}
    } else {
	if ($qe{$_}) {
	    print "$qe{$_}\t$_\n";
	} else {
	    warn "$_ not in qe tab\n";
	}
    }
}

1;

################################################################################

