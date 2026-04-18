#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;

use lib "$ENV{'ORACC_BUILDS'}/lib";

use Getopt::Long;

GetOptions(
    );

my $currtext = ();

my $curr_l = '';
my $curr_s = '';
my $ldata = '';
my $sdata = '';
my @lcols = ();
my @scols = ();

my $f = 'matrices.atf';
open(L,'>sepm-align.log');
open(M,$f);
while (<M>) {
    chomp;
    if (/^[-#*]/) {
    } elsif (/^(\d\S*?)\.\s+(.*?)\s*$/) {
	($curr_l,$ldata) = ($1,$2);
	@lcols = split_l($ldata);
    } elsif (/^(\S+?):\s+(.*?)\s*$/) {
	($curr_s,$sdata) = ($1,$2);
	if ($#lcols >= 0
	    && ($sdata =~ /[.o+]/ && $sdata !~ /(?:^\()|(?:^%a)|broken|erasure|omits|traces/)) {
	    @scols = split_s($sdata);
	    if ($#lcols != $#scols) {
		warn "$f:$.: $currtext: wanted $#lcols cols but found $#scols\n";
	    }
	} else {
	    # warn "$f:$.: ignoring $sdata\n";
	}
    } elsif (/^&/) {
	($currtext) = (/^.(\S+)/);
    }
}

1;

################################################################################

sub split_l {
    my @c = split(/[- ]/, $_[0]);
    my @n = ();
    foreach my $c (@c) {
	if ($c =~ s/\}(?=\S)/\} /
	    ||$c =~ s/(?<=\S)\{/ \{/) {
	    push @n, split(/\s/, $c);
	} elsif ($c =~ /[A-ZŠ][₀-₉]*\./) {
	    push @n, split(/\./, $c);
	} else {
	    push @n, $c;
	}
    }
    grep (length, @n);
}

sub split_s {
    my $x = shift;
    print L "$curr_l:$curr_s\n$x\n";
    $x =~ s#\s+/#/#g;
    $x =~ s/\.\.\./. . ./;
    $x =~ s/(\S)\+/$1 +/g;
    # The data as we are processing it does not distinguish between an
    # inserted sign and a sign that replaces the composite column's
    # sign. Try splitting what we have, and if it's the right number
    # of columns don't do any further processing.
    my @t = split(/\s+/, $x);
    if ($#t == $#lcols) {
	return @t;
    }
    # Now try mapping + in + to +in + and see if that helps
    $x =~ s/([.+o])\s+([áéíúàèìùabdegŋhiklmnprsštuwxz⸢])/$1$2/i;
    $x =~ s/([áéíúàèìùabdegŋhiklmnprsštuwxz⸣])([.+o])/$1 $2/i;
    print L "$x\n======\n";
    split(/\s+/, $x);
}
