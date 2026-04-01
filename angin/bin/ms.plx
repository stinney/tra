#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;

use lib "$ENV{'ORACC_BUILDS'}/lib";

use Getopt::Long;

GetOptions(
    );

my %tsv = (); my %mss = (); my %cdli = ();

my @t = `cut -f1,3-5,11 00lib/cat.tsv`; chomp @t;
my @m = `cat mss`; chomp @m;
my @c = `cat mss.cdli`; chomp @c;

foreach (@c) {
    my($m,$c) = (/^(.*?)\s+cdli:(.*?)$/);
    $cdli{$m} = $c;
}

foreach (@m) {
    next if /^\s*$/;
    my($s,$m,$p,$l) = split(/\t/,$_);
    die $_ unless $l;
    my $xm = $m;
    $xm =~ s/\(?\+.*$//;
    if ($m =~ /3NT/) {
	$xm =~ s/NT /NT0/;
	$xm =~ s/\s+\(.*$//;
    } else {
	$xm =~ s/^.*?\((.*?)\).*$/$1/;
    }
    print "$m\n" unless $cdli{$xm};
    @{$mss{$cdli{$xm}}}{qw/s m p l/} = ($s,$m,$p,$l);
}

print "cooper\tid_text\tsiglum\tcooper\tpub\tmusno\texcno\tprov\tper\tlines\n";
foreach (@t) {
    my($id,$pr,$m,$e,$pe) = split(/\t/,$_);
    $pe =~ s/\s+\(.*$//;
    $pr =~ s/\s+\(.*$//;
    if ($mss{$id}) {
	my %ms = %{$mss{$id}};
	print "$ms{'s'}\t$id\t\t$ms{'s'}\t$ms{'p'}\t$m\t$e\t$pr\t$pe\t$ms{'l'}\n";
    } else {
	print "\t$id\t\t\t$m\t$e\t$pr\t$pe\t\n";
    }
}

1;

################################################################################

