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
    } elsif (/^(\S+?)\**\s/ && $ms{$1}) {
	my $ms = $1;
    } elsif (/^\s*$/ || /^\#/) {
    } elsif (/^[\*\#]/) {
    } elsif (/^&/) {
	($currtext) = (/^.(\S+)/);
    } else {
	chomp;
	warn "$f:$.: $currtext:$currline: bad SOL: $_\n";
    }
    
}

1;
