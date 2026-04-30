#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;

use lib "$ENV{'ORACC_BUILDS'}/lib";

use Getopt::Long;

GetOptions(
    );

my %s = (); my @s = `cat ../bin/sigla.tsv`; chomp @s;
foreach (@s) { my($p,$s) = split(/\t/,$_); $s{$p} = $s; }

my %i = ();

#print Dumper \%s;

my $f = <>;
print $f;
while (<>) {
    my %f = ();
    my @f = split(/\t/, $_);
    @f{qw/id_text siglum vandijk designation pub musno excno prov per lines/} = @f;
    my $sigbase = $s{$f{'prov'}};
    my $sig = sprintf("%s%d", $sigbase, ++$i{$sigbase});
    $sig =~ tr/0-9/₀-₉/;
    $f{'siglum'} = $sig;
    print join("\t", @f{qw/id_text siglum vandijk designation pub musno excno prov per lines/});
}

1;

################################################################################

