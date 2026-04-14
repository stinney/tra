#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;
use lib "$ENV{'ORACC'}/lib";
use ORACC::CBD::Bases;

my $trace = 1;

my $cf = '';
my $curr_cfgw = '';

bases_init();
while (<>) {
    if (/^[-+>]?\@(entry|bases)/) {
	if (/^[-+>]?\@entry\!?\s+(.*?)\s*$/) {
	    $cf = $curr_cfgw = $1;
	    $cf =~ s/\s+\[.*$//;
	    $curr_cfgw =~ s/\s+\[(.*?)\]\s+/[$1]/;
	} else {
	    if ($curr_cfgw =~ /\]\s*V/) {
		s/^\@bases\s+//;
		my %b = bases_hash($_);
		my @b = grep(!/\#/, sort keys %b) if scalar keys %b;
		foreach my $b (@b) {
		    $b =~ s/\{.*?\}//g;
		    $b =~ s/^[aeiu]°//;
		    $b =~ s/·[aeiu]$//;
		    redup($b) if $b =~ /-/;
		}
	    }
	}
    }
}
bases_term();

##########################################################################

sub ineligible {
    my $x = shift;
    my $o = $x;
    $x =~ tr/-°·₀-₉//d;
    my $ok = ($x =~ /([bdgŋhḫklmnprsštwyz][aeiu])\1/);
    warn "ineligible $o => $x\n"
	if !$ok && $trace;
    return !$ok;
}

sub longest_seg {
    my @seg = sort { length($b) <=> length($a) } split(/-/, $_[0]);
    return $seg[0];
}

sub redup {
    my $s = shift;
    my $o = $s;

    warn "redup: $s\n"
	if $trace;

    # detect R-reduplication where writings are fully reduplicated
    my $RR = 0;

    $s =~ s/ₓ\(.*?\)//g;
    $s =~ tr/₀-₉//d;

    my $b = $s;
    $b =~ s/\{.*?\}//g;
    $b = longest_seg($b);
    my $bq = quotemeta($b);
    
    #detect symmetrical reduplication
    if ($s =~ m/^$bq(-$bq)+$/) {
	warn "redup: symmetrical $s\n"
	    if $trace;
	my $r = ($b eq $cf ? 'R' : 'r');
	my $n = ($s =~ tr/-/-/)+1;
	my $stem = "$r"x$n;
	$s =~ tr/-/·/;
	print "$curr_cfgw\t$o\t$stem\t$s\n";
	return;
    }

    #detect asymetrical reduplication
    my $cv = $bq;
    $cv =~ s/[bdgŋhḫklmnprsštwyz]$//;
    warn "redup: bq=$bq; cv=$cv\n"
	if $trace;
    if ($s =~ m/^($bq|$cv)(?:-(?:$bq|$cv))+$/) {
	warn "redup: asymetrical $s\n"
	    if $trace;
	my @r = ();
	my @x = split(/-/, $s);
	foreach my $x (@x) {
	    if ($x eq $bq) {
		push @r, 'R';
	    } else {
		push @r, 'r';
	    }
	}
	my $stem = join('', @r);
	$s =~ tr/-/·/;
	print "$curr_cfgw\t$o\t$stem\t$s\n";
	return;
    }

    #detect disyllabic reduplication
    warn "redup: disyll test on $s\n"
	if $trace;
    my @seg = split(/-/, $s);
    my $x12 = "$seg[0]$seg[1]";
    $x12 =~ s/([aeiu])\1/$1/g;
    my $xcf = $cf;
    $xcf =~ s/[ie]/[ie]/g;
    if ($x12 =~ /^$xcf[aeiu]?$/) {	    
	warn "redup: syll s1s2 = $x12\n"
	    if $trace;
	my $x12h = "$seg[0]-$seg[1]";
	warn "disyll try $x12h on $s\n"
	    if $trace;
	return if $x12h eq $s;
	if ($s =~ m/^$x12h(?:-$x12h)+$/) {
	    my @x = ($s =~ m/^($x12h)(?:(-$x12h))+$/);
	    my @n = ();
	    foreach my $x (@x) {
		$x =~ tr/-//;
		push @n, $x;
	    }
	    $s = join('-',@n);
	    $s =~ tr/-/·/;
	    $s =~ s/··/\000/; $s =~ tr/·/°/; $s =~ s/\000/·/;
	    my $stem = "R′R′";
	    print "$curr_cfgw\t$o\t$stem\t$s\n";
	    return;
	} elsif ($s =~ /^$x12h-([^-]+)$/) {
	    my $bit = $1;
	    if ($cf =~ /^$bit/) {
		my $stem = "R′r";
		$x12h =~ tr/-/°/;
		$s = "$x12h·$bit";
		print "$curr_cfgw\t$o\t$stem\t$s\n";
		return;
	    }
	}
    }

    return if ineligible($o);
    
    warn "redup: never solved $s\n"
	if $trace;

    return;
}

1;
