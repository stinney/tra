#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;

use lib "$ENV{'ORACC_BUILDS'}/lib";

use Getopt::Long;

GetOptions(
    );

my %q = ();

open(C,"epsd-royal-qcat.tsv") || die;
while (<C>) {
    /^(\S+)/;
    ++$q{$1};
}
close(C);

my $q = '';
my $lem = 0;
my $last_verb = '';
my $ruler = '';
my $arad = 0;
my $namtil = 0;
my $years = 0;
my $inum = -1;
my $alan = 0;
my $muname = 0;
my $ehouse = 0;

open(T, '>royal-types.tsv');
my $type = '-';
open(R,"$ENV{'ORACC'}/epsd2/royal/00atf/royal.atf") || die;
while (<R>) {
    if (/^\&(Q\d+)/) {
	my $thisq = $1;
	if ($years || $inum == 0) {
	    $type = 'Year names';
	} elsif ($last_verb eq 'build' || $last_verb eq 'return') {
	    $type = 'Building';
	} elsif ($last_verb eq 'offer' || $namtil) {
	    $type = 'Votive';
	} elsif ($last_verb eq 'donate') {
	    $type = 'Donation';
	} elsif ($arad) {
	    $type = 'Arad-seal';
	} elsif ($inum >= 2000) {
	    $type = 'Seal';
	} elsif ($inum >= 1000) {
	    $type = 'Family';
	} elsif ($alan && $muname) {
	    $type = 'Statue';
	} elsif ($ruler eq 'Gudea' || $ehouse) {
	    $type = 'Building';
	} elsif ($lem > 10000) {
	    $type = 'Narrative';
	} elsif ($lem >= 10) {
	    $type = 'Narrative';
	} elsif ($lem < 6) {
	    $type = 'uncertain';
	} else {
	    $type = 'unidentified';
	}
    
	warn "$q: unidentified type\n" unless $type;
	$type = 'unidentified' unless $type;
	print T "$q\t$type\n" unless $type eq '-';

	$q = $thisq;
	warn "$q in royal but not in qcat\n" unless $q{$q};
	$last_verb = $type = '';
	$ehouse = $alan = $muname = $lem = $arad = $namtil = $years = 0;
	($ruler) = (/\s+=\s+(\S+)/);
	if (/\s(\d+)(?:add|\s+\[|$)/) {
	    $inum = $1;
	} else {
	    $inum = -1;
	}
	if (/\sYN\s/) {
	    $years = 1;
	} elsif (/\sStatue/i) {
	    $alan = 1; $muname =1;
	} elsif (/\sCyl/) {
	    $lem = 10000;
	}
    } elsif (/^#lem:/) {
	++$lem;
	if (/namtil\[life/) {
	    $namtil = 1;
	} elsif (/arad\[servant/) {
	    $arad = 1;
	} else {
	    if (/alan\[statue/) {
		$alan = 1;
	    }
	    if (/mu\[name/) {
		$muname = 1;
	    }
	    if (/e\[house/) {
		$ehouse = 1;
	    }
	}
	if (/\s!?du\[build/) {
	    $last_verb = 'build';
	} elsif (/\sgi\[.*?turn/) {
	    $last_verb = 'return';
	} elsif (/\srig\[donate/) {
	    $last_verb = 'offer';
	} elsif (/\sru\[cvve/) {
	    $last_verb = 'offer';
	}
    }
}
close(R);
close(T);

1;

################################################################################

