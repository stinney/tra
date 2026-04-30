#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;

use lib "$ENV{'ORACC_BUILDS'}/lib";

use Getopt::Long;

GetOptions(
    );

my %k1 = ();
my %k2 = ();

my @s = `cat 00lib/cat.tsv`;
my $f = shift @s;
foreach (@s) {
    my %f = ();
    my @f = split(/\t/, $_);
    @f{qw/id_text siglum vandijk designation pub musno excno prov per lines/} = @f;
    my $k1 = $f{'lines'};
    my $k2 = $f{'vandijk'};
    $k1 =~ s/[ivx]+\s-;//g;
    $k1 =~ s/^-;\s+//;
    $k1 =~ s/[-,;].*$//;
    $k1 =~ tr/0-9//cd;
    $k1 = 999 unless $k1 =~ /^\d/;
    $k2 = '~' unless $k2;
    $k2 =~ tr/()//d;
    $k1{$f{'id_text'}} = $k1;
    $k1{$f{'id_text'}} = $k1;
    $k2{$f{'id_text'}} = $k2;
    $k2{$f{'id_text'}} = $k2;
}

print $f;
print sort { &s } @s;

1;

################################################################################

sub s {
    my($id1) = ($a =~ /^(\S+)/);
    my($id2) = ($b =~ /^(\S+)/);
    my $id1k1 = $k1{$id1};
    my $id2k1 = $k1{$id2};
    my $id1k2 = $k2{$id1};
    my $id2k2 = $k2{$id2};

    my $ret = $id1k1 <=> $id2k1;
    unless ($ret) {
	return $id1k2 cmp $id2k2;
    }
    return $ret;    
}
