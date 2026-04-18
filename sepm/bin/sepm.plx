#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;

use lib "$ENV{'ORACC_BUILDS'}/lib";

use Getopt::Long;

GetOptions(
    );

my %Q = (); foreach (`cat 33.Q`) { chomp; my($c,$q)=split(/\t/,$_); $Q{$c} = $q; }

my $tra = 1;

my $f = '00raw/SEpM-eds-no-mat.txt';
open(F, $f);

while (<F>) {
    if (/^\&/) {
	my ($c) = (/([0-9]\.[0-9]\.[0-9]+(?:\.a)?)\)$/);
	($c) = (/(5\.7\.a|3\.99\.a|3\.99)/) unless $c;
	$c =~ s/\.([0-9])$/.0$1/ || $c =~ s/\.5\.a/.05.a/;
	warn "$f:$.: no CSL number\n" unless $c;
	warn "$f:$.: no Q number for `$c'\n" unless $Q{$c};
	warn "$f:$.: no \@tra\n" unless $tra;
	s/^&/\&$Q{$c} = /;
	$tra = 0;
	print;
	print "#project: tra/sepm\n#atf: use unicode\n#atf: use legacy\n#atf: use math\n\n";
	print "#key: after A. Kleinerman, CM 24\n\n";
	next;
    } elsif (/^(\d+[AB]?\.)\s(.*?)\s*$/) {
	chomp;
	my($lnum,$line) = ($1,$2);
	$line = tlitfix($line);
	$_ = "$lnum\t$line\n";
    } elsif (/^\@tra/) {
	$tra = 1;
	print "\n\@translation labeled en project\n\n";
	next;
    } elsif (/^\$/) {
    } elsif (/^\^/ || /^Var/ || /^\t/) {
    } elsif (/^\s*$/) {
    } elsif ($tra) {
	if (/^\(\d/) {
	    s/^\((\d+)-(\d+)\)/($1 - $2)/;
	    s/^/\n\@/;
	}
	s/ \(([0-9].*?)\)/ \@lab{$1}/g;
    } else {
	chomp;
	warn "$f:$.: bad SOL: $_\n" unless $tra;
    }
    print;
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
    $l =~ s/m(ad|ba|ig|inim|li|lugal|lú|mes|nu|saŋ|si|ul|zu)/{m}$1/g;
    $l =~ s/d(alad₂|amar|bil₄|da|en|inana|lamma|namma|nergal|nidaba|nu|utu)/\{d\}$1/g;
    $l =~ s/dkab/{d}kab/g;
    $l =~ s/dnin/{d}nin/g;
    $l =~ s/dsuen/{d}suen/g;
    $l =~ s/dšul/{d}šul/g;
    $l =~ s/(al|àm|dana|dar|eridug|in|iri|nibru|qum|ta|tum|um|unug|urim?₂)ki/$1\{ki\}/g;
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
