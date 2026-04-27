#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8; use feature 'unicode_strings';
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
binmode $DB::OUT, ':utf8' if $DB::OUT;

use Data::Dumper;

use lib "$ENV{'ORACC_BUILDS'}/lib";

use Getopt::Long;

my %per = (
    'ED IIIa'=>'ED',
    'ED IIIb'=>'ED',
    'Ebla'=>'ED',
    'Ur III'=>'U3',
    'Old Akkadian'=>'OA',
    'Old Babylonian'=>'OB',
    'Neo-Babylonian'=>'FM',
    'Neo-Assyrian'=>'FM',
    );

GetOptions(
    );

while (<>) {
    next if /^id_text/ || /^\s*$/;
    chomp;
    my ($p,$bit,$d,$lng,$mus,$per,$pri,$sub,$dme) = split(/\t/, $_);

    my $div = '';
    if ($lng ne 'Akkadian') {
	if ($per) {
	    $div = "$per{$per} Praxis";
	} else {
	    warn "$p: no period\n";
	}
    }

    my $des = '';
    if ($pri || $mus) {
	$des = $pri;
	$des = $mus unless $pri;
	$des .= " $bit" if $bit;
	if ($dme) {
	    $dme =~ s/GC/DME/;
	    $dme =~ s/n//;
	    $des .= " ($dme)";
	}
    } else {
	warn "$p has empty pri and mus\n";
    }
    
    my $query = $d =~ s/^Possibly\s+//;
    $d =~ s/Probably\s+//i;
    $d =~ s/^Directed\s+//i;
    if ($d =~ /pests/) {
	$d =~ s/^against/agricultural/i;
    }
    my $sb = '';
    my $fo = '';
    if ($d =~ /^against/i || $d =~ /Udugh/ || $d =~ /protective/i) {
	$sb = 'Against';
	if ($d =~ /(galla|evil (?:udug|daimon)|Namtar|Lamaštu|asag|gidim|demon|daimon|Ardat Lilî|Udughul)/) {
	    $fo = $1;
	    $sb = 'Anti-demon';
	    $fo =~ s/daimon/demon/;
	} elsif ($d =~ /(evil (?:eye|mouth|tongue)|witchcraft|anger|curse|opponent)/) {
	    $sb = 'Anti-malice';
	    $fo = $1;
	} elsif ($d =~ /(snake|scorpion|dog|worm|flies)/) {
	    $fo = $1;
	    $fo = 'snake/scorpion' if $fo =~ /snake|scorpion/;
	    $sb = 'Anti-animal';
	} elsif ($d =~ /(\S+[-\s](?:disease|illness))/
		 || $d =~ /(headache|constipation|bile|jaundice|toothache|suffering|seizure|samana|merḫu|sleep|dreams)/) {
	    $fo = $1;
	    $sb = 'Anti-illness';
	} elsif ($d =~ /eclipse/) {
	    $fo = 'eclipse';
	    $sb = 'Royal';
	} else {
	    warn "against: $d\n";
	}
	# print "$p\t$sb\t$fo\n";
    } elsif ($d =~ /^Therapeutic/i) {
	$sb = 'Therapeutic';
	if ($d =~ /releasing\s+(\S+)/ || /(recovering|cattle disease|paralysis)/) {
	    $fo = $1;
	} elsif ($d =~ /(exorcising|exorcism|incantation|ušumgal)/) {
	    $fo = $1;
	} elsif ($d =~ /(daimon|ala|Asag)/) {
	    $fo = 'demon';
	} elsif ($d =~ /similar/) {
	    $fo = 'scape-goat';
	} elsif ($d =~ /Therapeutic/) {
	    $fo = 'unspecified';
	} else {
	    warn "therapeutic: $d\n";
	}
	# print "$p\tTherapeutic\t$fo\n";
    } elsif ($d =~ /^temple/i || $d =~ /mouth/) {
	if (/mouth/) {
	    $fo = 'mouth-opening';
	} elsif (/found/) {
	    $fo = 'foundation';
	} else {
	    warn "temple: $d\n";
	}
	$sb = 'Cult';
	# print "$p\tCult\t$fo\n";
    } elsif ($d =~ /^consecration/i || $d =~ /^Purification/) {
	if ($sub) {
	    if ($sub =~ /(reed-torch|fermenting vat|date-cluster|water|oil)/) {
		$fo = $1;
		$fo =~ s/water/holy water/;
	    } else {
		# warn "consecration: $sub\n";
	    }
	} else {
	    # warn "consecration: $d\n";
	}
	$sb = 'Consecration';
	# print "$p\tConsecration\t$fo\n";
    } elsif ($d =~ s/^agricultural//i || $d =~ /field/i) {
	if (/pest|roden/) {
	    $fo = 'pests';
	} elsif (/illn/) {
	    $fo = 'animal illness';
	} elsif (/^\s*/) {
	    $fo = 'unspecified';
	} else {
	    warn "agricultural: $d\n";
	}
	$sb = 'Agriculture';
	# print "$p\tAgricultural\t$fo\n";
    } elsif ($d =~ /^(love|birth|pregnancy|arousal)/i || $d =~ /pre-natal/ || $d =~ /baby/) {
	if (/love/i) {
	    $fo = 'love';
	} elsif (/baby/i) {
	    $fo = 'baby';
	} elsif (/birth/i || /natal/i) {
	    $fo = 'birth';
	} elsif (/preg/i) {
	    $fo = 'pregnancy';
	} else {
	    warn "love/birth: $d\n";
	}
	$sb = 'Love/Birth';
	# print "$p\tLove/Birth\t$fo\n";
    } elsif ($d =~ s/^ritual//i) {
	if (/figuri/) {
	    $fo = 'figurine';
	} elsif (/^\s*/) {
	    $fo = 'unspecified';
	} else {
	    warn "ritual: $d\n";
	}
	$sb = 'Ritual';
	# print "$p\tRitual\t$fo\n";
    } elsif ($d =~ /^amulet/i) {
	$sb = 'Amulet';
	# print "$p\tAmulet\t\n";
    } elsif ($d =~ /^royal/i || $d =~ /^military/i) {
	$sb = 'Royal';
	# print "$p\tRoyal\t\n";
    } elsif ($d =~ /scapegoat|propitiation|snake-charm|recipe|proverb|releasing/i) {
	$sb = 'Varia';
	# print "$p\tVaria\t\n";
    } elsif ($d =~ /^tag/) {
	$sb = 'Catalogue';
	# print "$p\tCatalogue\t\n";
    } elsif ($d =~ /uncertain/i) {
	$sb = 'Uncertain';
	# print "$p\tUncertain\t\n";
    } elsif ($d =~ /^\s*/) {
	$sb = 'Unspecified';
	# print "$p\tUnknown\t\n";
    } else {
	warn "$_ not handled\n";
    }
    if ($div) {
	print "$p\t$div\t$sb\t$fo\t$des\n";
    }
}

1;

################################################################################

