#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;

use lib "$ENV{'ORACC_BUILDS'}/lib";

use Getopt::Long;

my %per = (
    'Early Dynastic'=>'ED',
    'Lagaš II'=>'L2',
    'Ebla'=>'ED',
    'Ur III'=>'U3',
    'Ur III?'=>'U3',
    'Old Akkadian'=>'OA',
    'Old Babylonian'=>'OB',
    'Old Babylonian?'=>'OB',
    'Early Old Babylonian'=>'OB',
    'Neo-Babylonian'=>'FM',
    'Neo-Assyrian'=>'FM',
    );

my %t = (); my @t = `cat royal-types.tsv`; chomp(@t);
foreach (@t) { my($q,$t)=split(/\t/,$_); $t{$q} = $t; }

GetOptions(
    );

while (<>) {
    chomp;
    my($q,$r,$n,$p,$c) = split(/\t/,$_);
    warn "$p\n" unless $per{$p};
    my $rim = '';
    $rim = " \[$n\]" if $n;
    warn "$.: $q: bad t{q}\n" unless $t{$q};
    my $t = 'undefined';
    $t = $t{$q} if $t{$q};
    # my $f = $r; $f =~ s/\s+\d.*$//;
    print "$q\t$per{$p} Royal\t$t\t$c\t$r$rim\n";
}

1;

################################################################################

