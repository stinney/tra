#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;

use lib "$ENV{'ORACC_BUILDS'}/lib";

use Getopt::Long;

GetOptions(
    );

my %sb = load_g('g2');
my %g3 = load_g('g3');

my @c = `cat ~/orc/ucsl/etcsl/00lib/cat.d/grpdes.tsv`; chomp @c;
<>;
foreach (@c) {
    my($q,$g1,$g2,$g3,$g4,$x,$y,$d) = split(/\t/,$_);
    my $sb = '';
    if ($sb{$g3}) {
	$sb = $sb{$g3};
    } elsif ($sb{$g2}) {
	$sb = $sb{$g2};
    } elsif (/catalogue/) {
	$sb = 'Catalogue';
    } else {
	warn "$q: $d: no SB\n";
    }
    my $fo = '';
    if ($g4 ne '-') {
	$fo = $g4;
    } elsif ($g3) {
	$fo = $g3;
    } else {
	warn "$q: $d: no FO\n";
    }
    if ($sb && $fo) {
	$fo =~ s/thers/ther/;
	print "$q\tOB Lit\t$sb\t$fo\t$d\n";
    }
}

1;

################################################################################

sub load_g {
    my @g = `cat $_[0]`; chomp @g;
    my %g = ();
    foreach (@g) {
	my($t,$f) = split(/\t/,$_);
	warn "$t\n" unless $f;
	$g{$f} = $t;
    }
    %g;
}
