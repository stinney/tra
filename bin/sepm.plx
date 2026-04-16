#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;

use lib "$ENV{'ORACC_BUILDS'}/lib";

use Getopt::Long;

GetOptions(
    );

my $tra = 1;

my $f = 'SEpM-eds-no-mat.txt';
open(F, $f);

while (<F>) {
    if (/^\&/) {
	warn "$f:$.: no \@tra\n" unless $tra;
	$tra = 0;
    } elsif (/^(\d+[AB]?\.)\s(.*?)\s*$/) {
	chomp;
	my($lnum,$line) = ($1,$2);
	$line = tlitfix($line);
	$_ = "$lnum\t$line\n";
    } elsif (/^\@tra/) {
	$tra = 1;
    } elsif (/^\$/) {
    } elsif (/^\^/ || /^Var/ || /^\t/) {
    } elsif (/^\s*$/) {
    } else {
	chomp;
	warn "$f:$.: bad SOL: $_\n" unless $tra;
    }
    print unless $tra;
}

close(F);

##############################################################



sub tlitfix {
    my $l = shift;
    $l =~ tr/@/ŋ/;
    $l =~ s/([abdegŋhiklmnprsštuwxz])([0-9]+)/subdig($1,$2)/eg;
    $l =~ s/([áéíúàèìùabdegŋhiklmnprsštuwxz₀-₉])mušen/$1\{mušen\}/g;
    $l =~ s/(ŋiš|íd|na₄|lú)([áéíúàèìùabdegŋhiklmnprsštuwxz₀-₉])/\{$1\}$2/g;
    $l =~ s/md/{m}{d}/g;
    $l =~ s/m(ad|ba|inim|li|lugal|lú|mes|nu|saŋ|si|ul|zu)/{m}$1/g;
    $l =~ s/d(alad₂|da|en|inana|lamma|nergal|nidaba|utu)/\{d\}$1/g;
    $l =~ s/dkab/{d}kab/g;
    $l =~ s/dnin/{d}nin/g;
    $l =~ s/dsuen/{d}suen/g;
    $l =~ s/dšul/{d}šul/g;
    $l =~ s/(al|àm|dana|dar|eridug|in|iri|nibru|qum|ta|tum|um|unuq|urim?₂)ki/$1\{ki\}/g;
    $l =~ s/gi(bisaŋ)/{gi}bisaŋ/g;
    $l =~ s#/(\S+)\\#⸢$1⸣#g;
    $l;
}

sub subdig {
    my($let,$dig) = @_;
    $dig =~ tr/0-9/₀-₉/;
    "$let$dig"
}

1;
