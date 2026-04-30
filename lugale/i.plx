#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;

use lib "$ENV{'ORACC_BUILDS'}/lib";

use Getopt::Long;

GetOptions(
    );

my $trace = 1;

my %pl = (); my @pl = `cat plates.tsv`; chomp @pl;
foreach (@pl) { my($s,$p) = split(/\t/, $_); $pl{$s} = $p }

$/ = "\n\n";
my $s = '';
Roman::init();
while (<>) {
    chomp;
    ($s) = (/^(\S+)/);
    my @l = split(/\n/, $_);
    # printf "$s has %d lines\n", $#l+1;
    warn "$s has no \@\@\n" unless $l[0] =~ /\@\@/;
    my($x,$pub) = split(/\@\@/, $l[0]);
    $pub =~ s/^\s*(.*?)\s*$/$1/;
    if ($pl{$s}) {
	my @pub = split(/;/, $pub);
	my $vd = 0;
	my @n = ();
	foreach my $pb (@pub) {
	    $pb =~ s#/.*$##;
	    if ($pb =~ s/Bergmann|(?:v\.?\s+)?Dijk|Durand|Finkel|Geller|Lambert//) {
		$vd = 1;
		push @n, "van Dijk pl. $pl{$s}";
		$pb =~ s/^\s*$//;
		warn "$s has spurious van Dijk text `$pb'\n" if length $pb;
	    } else {
		push @n, $pb;
	    }
	}
	$pub = join("; ", @n);
    }
    my $lines = lines(@l[1..$#l]);
    print "$s\t$pub\t$lines\n";
}

1;

################################################################################

sub lines {
    my @x = @_;
    warn "===\n", join("\n", @x), "\n"
	if $trace;
    for (my $i = 0; $i <= $#x; ++$i) {
	$x[$i] =~ s/\s*\@\@=/=/;
	$x[$i] =~ s/\s*\@\@\s*//;
	if ($x[$i] =~ s/^(\(.*?\)\s*)//) {
	    warn "removing `$1'\n"
		if $trace;
	}
	$x[$i] =~ s/\[col.*?\]//;
	$x[$i] =~ s/^\s+$//;
    }
    @x = grep length, @x;
    warn "---\n", join("\n", @x), "\n===\n"
	if $trace;
    my $f_or_r = 0;
    my @ll = ();
    for (my $i = 0; $i < $#x; ++$i) {
	my $bang = 0;
	warn "$s: $x[$i]\n"
	    unless $x[$i] =~ /^([0-9]+|f\.\!?(?:\s+[0-9]+)?|r(?:ev)?\.\!?(?:\s+[0-9]+)?)\s*=\s*/;
	if ($x[$i] =~ s/^f\.//) {
	    $bang = $x[$i] =~ s/^\s*\!//;
	} elsif ($x[$i] =~ s/^r(?:ev)?\.//) {
	    $f_or_r = 1;
	    $bang = $x[$i] =~ s/^\s*\!//;
	}
	$x[$i] =~ s/^\s*//;
	warn "$s: x[$i] after f./r.: `$x[$i]'\n"
	    if $trace;
	my $col = '';
	if ($x[$i] =~ s/^\s*([0-9]+)(\s|=)//) {
	    my $ar = $1;
	    $col = Roman::roman($ar);
	    warn "col = $col\n";
	}
	$x[$i] =~ s/^\s*//; $x[$i] =~ s/^=\s*//;
	warn "$s: x[$i] after col: `$x[$i]'\n"
	    if $trace;
	$x[$i] =~ s/^\s*(?:\([!?]\)\s*)//;
	if ($x[$i] =~ /^(\d+[--]\d+)/) {
	    my $ll = $x[$i];
	    $ll = "$col $ll" if $col;
	    $ll = "r $ll" if $f_or_r;
	    $ll =~ tr/;/,/;
	    push @ll, $ll;
	} elsif ($x[$i] =~ /^perd/) {
	    my $ll = "-";
	    $ll = "$col $ll" if $col;
	    push @ll, $ll;
	} else {
	    warn "$s: $x[$i] (considered acceptable)\n";
	    my $ll = $x[$i];
	    $ll = "$col $ll" if $col;
	    $ll = "r $ll" if $f_or_r;
	    $ll =~ tr/;/,/;
	    push @ll, $ll;
	}
    }
    join('; ', @ll);
}

### Adapted/cut down from
###   http://search.cpan.org/src/OZAWA/Roman-1.1/Roman.pm
### by Steve Tinney 2006-10-30.

package Roman;

my %roman_digit = ();
my @figure = ();

=head1 NAME

Roman - Perl module for conversion between Roman and Arabic numerals.

=head1 SYNOPSIS

	use Roman;

	$roman = Roman($arabic);
	$roman = roman($arabic);

=head1 DESCRIPTION

This package provides some functions which help conversion of numeric
notation between Roman and Arabic.

=head1 BUGS

Domain of valid Roman numerals is limited to less than 4000, since
proper Roman digits for the rest are not available in ASCII.

=head1 CHANGES

1997/09/03 Author's address is now <ozawa@aisoft.co.jp>

=head1 AUTHOR

OZAWA Sakuro <ozawa@aisoft.co.jp>

=head1 COPYRIGHT

Copyright (c) 1995 OZAWA Sakuro.  All rights reserved.  This program
is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

=cut

sub init {
    %roman_digit = qw(1 IV 10 XL 100 CD 1000 MMMMMM);
    @figure = reverse sort keys %roman_digit;
    grep($roman_digit{$_} = [split(//, $roman_digit{$_}, 2)], @figure);
}

sub Roman {
    my($arg) = shift;
    0 < $arg and $arg < 4000 or return undef;
    my($x, $roman);
    foreach (@figure) {
        my($digit, $i, $v) = (int($arg / $_), @{$roman_digit{$_}});
        if (1 <= $digit and $digit <= 3) {
            $roman .= $i x $digit;
        } elsif ($digit == 4) {
            $roman .= "$i$v";
        } elsif ($digit == 5) {
            $roman .= $v;
        } elsif (6 <= $digit and $digit <= 8) {
            $roman .= $v . $i x ($digit - 5);
        } elsif ($digit == 9) {
            $roman .= "$i$x";
        }
        $arg -= $digit * $_;
        $x = $i;
    }
    $roman;
}

sub roman {
    lc Roman shift;
}
