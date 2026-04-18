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

my @block = ();
my $f = 'matrices.atf';
open(L,'>sepm-align.log');
open(M,$f);
while (<M>) {
    chomp;
    if (/^[-#*]/) {
	push @block, [ 0 ];
    } elsif (/^(\d\S*?)\.\s+(.*?)\s*$/) {
	print_block() if $#block >= 0;
	($curr_l,$ldata) = ($1,$2);
	@lcols = split_l($ldata);
	push @block, [ 1, @lcols ];
    } elsif (/^(\S+?):\s+(.*?)\s*$/) {
	($curr_s,$sdata) = ($1,$2);
	if ($#lcols >= 0
	    && ($sdata =~ /[.o+]/ && $sdata !~ /(?:^\()|(?:^%a)|broken|erasure|omits|traces/)) {
	    @scols = split_s($sdata);
	    if ($#lcols != $#scols) {
		warn "$f:$.: $currtext: wanted $#lcols cols but found $#scols\n";
	    }
	    push @block, [ 1 , @scols ];
	} else {
	    # warn "$f:$.: ignoring $sdata\n";
	    push @block, [ 0 , @scols ];
	}
    } elsif (/^&/) {
	($currtext) = (/^.(\S+)/);
	print "$_\n";
    } else {
	warn "$.: untrapped line\n" unless /^\s*$/;
    }
}

1;

################################################################################

sub format_block {
    my @b = @_;
    @b;
}

sub print_block {
    my $todo = 0;
    for (my $i = 0; $i <= $#block; ++$i) {
	$todo += $block[$i][0];
    }
    print "block has $todo rows to process\n";
    if ($todo) {
	@block = format_block(@block);
    }
    foreach (my $i = 0; $i <= $#block; ++$i) {
	my @b = @{$block[$i]};
	shift @b;
	my $l = join('', @b);
	print "$l\n";
    }
    print "\n";
    @block = ();
}

sub split_l {
    my $l = shift;
    my @c = split(/[- ]/, $l);
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
