#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;

use lib "$ENV{'ORACC_BUILDS'}/lib";

use Getopt::Long;

GetOptions(
    );

my %ms = (); foreach (`cut -f1 sepm-cat.tsv`) { next if /^number/i; chomp; s/\s.*$//; ++$ms{$_}; }

my @xms = qw/X17a X17b X17c X17d/; foreach (@xms) { ++$ms{$_} }

my $f = $ARGV[0];

my $currtext = '';
my $currline = '';

while (<>) {
    if (/^(\d+[ABa-z]?)\.\s/) {
	$currline = $1;
	$_ = fixtlit($_);
    } elsif (/^(\S+?)\**\s/ && $ms{$1}) {
	my $ms = $1;
	$_ = fixwitness($_);
    } elsif (/^\s*$/ || /^\#/) {
    } elsif (/^[\*\#]/) {
    } elsif (/^&/) {
	($currtext) = (/^.(\S+)/);
    } else {
	chomp;
	warn "$f:$.: $currtext:$currline: bad SOL: $_\n";
    }
    s/\. \. \./.../;
    print;
}

##################################################################

sub fixtlit {
    my $l = shift;
    $l =~ tr/@/ŋ/;
    $l =~ s/([abdegŋhiklmnprsštuwxz])([0-9]+)/subdig($1,$2)/eg;
    $l =~ s/([áéíúàèìùabdegŋhiklmnprsštuwxz₀-₉])mušen/$1\{mušen\}/g;
    $l =~ s/(ŋiš|íd|na₄|lú)([áéíúàèìùabdegŋhiklmnprsštuwxz₀-₉])/\{$1\}$2/g;
    $l =~ s/m(ad|ba|ig|inim|li|lugal|lú|mes|nu|saŋ|si|ul|zu)/{m}$1/g;
    $l =~ s/d(alad₂|amar|bil₄|da|en|inana|lamma|namma|nergal|nidaba|nu|utu)/\{d\}$1/g;
    $l =~ s/dkab/{d}kab/g;
    $l =~ s/dnin/{d}nin/g;
    $l =~ s/dsuen/{d}suen/g;
    $l =~ s/dšul/{d}šul/g;
    $l =~ s/(al|àm|dana|dar|eridug|in|iri|nibru|qum|ta|tum|um|unug|urim?₂)ki/$1\{ki\}/g;
    $l =~ s/gi(bisaŋ)/{gi}bisaŋ/g;
    $l =~ s#/(\S+)\\#⸢$1⸣#g;
    $l =~ tr/æ/ŋ/;
    $l =~ s/ŋ (iš|ir|á|u₁₀|e₂₆)/ŋ$1/g;
    1 while $l =~ s/ (m|d|ŋiš|sar|kuš) / {$1} /;
    1 while $l =~ s/^(m|d|ŋiš|sar|kuš) /{$1} /;
    $l;
}

sub fixwitness {
    my $l = shift;
    chomp($l);
    my($s,$r) = ($l =~ /^(\S+)\s+(.*?)$/);
    $r = fixtlit($r);
    $l = "$s: $r\n";
    $l;
}

sub subdig {
    my($let,$dig) = @_;
    $dig =~ tr/0-9/₀-₉/;
    "$let$dig"
}

1;
