#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8;
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';

use Data::Dumper;
use lib "$ENV{'ORACC'}/lib";
use ORACC::CBD::Bases;

my $trace = 1;

my $curr_cfgw = '';

bases_init();
while (<>) {
    if (/^[-+>]?\@(entry|bases)/) {
	if (/^[-+>]?\@entry\!?\s+(.*?)\s*$/) {
	    $curr_cfgw = $1;
	} else {
	    if ($curr_cfgw =~ /\]\s*V/) {
		s/^\@bases\s+//;
		my %b = bases_hash($_);
		my @b = grep(!/\#/, sort keys %b) if scalar keys %b;
		foreach my $b (@b) {
		    redup($b);
		}
	    }
	}
    }
}
bases_term();

sub
redup {
    my $s = shift;
    warn "redup: $s\n"
	if $trace;

    # detect R-reduplication where writings are fully reduplicated
    my $RR = 0;

    my $b = $s;
    $b =~ s/\{.*?\}//g;
    my $bq = quotemeta($b);
    my $ba = $b; $ba =~ tr/₀-₉//d;
    my $baq = quotemeta($ba);
    if ($s =~ m/^$bq-$bq-$bq-$bq$/ || $s =~ m/^$baq-$baq-$baq-$baq$/) {
	print "$curr_cfgw\t$s RRRR $b\n";
	return;
    } elsif ($s =~ m/^$bq-$bq-$bq$/ || $s =~ m/^$baq-$baq-$baq$/) {
	print "$curr_cfgw\t$s RRR $b\n";
	return;
    } elsif ($s =~ m/^$bq-$bq$/ || $s =~ m/^$baq-$baq$/) {
	print "$curr_cfgw\t$s RR $b\n";
	return;
    }

    if ($s =~ /^(.*?)-\1$/) {
	print "$curr_cfgw\t$s *RR* $1\n";
	return;
    } elsif ($s =~ /^.*?-(.*?)-\1$/) {
	print "$curr_cfgw\t$s RR* $1\n";
	return;
    } elsif ($s =~ /^(.*?)-\1-$/) {
	print "$curr_cfgw\t$s *RR $1\n";
	return;
    }
    
    # detect r-reduplication where writings are incompletely reduplicated
    $b = $s;
    $b =~ tr/₀-₉//d;
    $b =~ tr/-//d;
    $b =~ s/\{.*?\}//g;
    $b =~ s/([aeiu])\1/$1/g;
    my $c = $curr_cfgw; $c =~ s/\s+\[.*$//;
    next unless length($b) > length($c);
    # is the first base R and the second r ?
    if ($b =~ /^$c(.*)$/) {
	my $bb = quotemeta($1);
	# warn "found $c as subset of $b with remnant $bb\n" if $c eq 'hal';
	if ($c eq $bb) {
	    # warn "$c/$s: got $c eq $bb for RR'\n" if $c eq 'ša';
	    print "$curr_cfgw\t$s RR' $c\n";
	    return;
	} elsif ($c =~ /^$bb/) {
	    # warn "$c/$s: got $c contains $bb for Rr\n" if $c eq 'hal';
	    print "$curr_cfgw\t$s Rr $c\n";
	    return;
	}	    
    }

    # is the first base r and the second R ?
    if ($b =~ /^(.*)$c$/) {
	my $bb = quotemeta($1);
	if ($c eq $bb) {
	    # warn "$c/$s: got $c eq $bb for RR'\n" if $c eq 'ša';
	    print "$curr_cfgw\t$s RR' $c\n";
	    return;
	} elsif ($c =~ /^$bb/) {
	    # warn "$c/$s: got $c contains $bb for rR\n" if $c eq 'hal';
	    print "$curr_cfgw\t$s rR $c\n";
	    return;
	}
    }

    if ($trace) {
	warn "redup: never solved $s\n";
    }
}

1;
