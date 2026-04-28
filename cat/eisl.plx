#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;

use lib "$ENV{'ORACC_BUILDS'}/lib";

use Getopt::Long;

GetOptions(
    );

open(F,'eisl-pre-ucsl.tsv') || die;
while (<F>) {
    chomp;
    my($q,$d,$p,$t) = split(/\t/,$_);
    if ($p ne 'First Millennium') {
	warn "$p\n" unless $p =~ /Old Bab/;
	next;
    }
    my $f = 'unknown';
    if ($d =~ /\s\(([^)]+)\)$/) {
	$f = $1;
	$f =~ s/deity/god/;
	if ($f =~ / /) {
	if ($f eq 'Emesal liturgy fragment') {
	    $f = 'unknown';
	} elsif ($f =~ /Unknown god/ || $f eq 'Personal God' || $f eq 'The great gods'
		 || $f eq 'An, Enlil, Enki' || $f =~ /\s(and|or)\s/) {
	} elsif ($f =~ s/^parallel.*;\s+//) {
	} else {
	    warn "f=$f\n";
	}
    }
    }
    print "$q\tFM Liturgy\t$t\t$f\t$d\n";
}
close(F);

1;

################################################################################

