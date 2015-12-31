#!/usr/bin/perl -wl

use strict;
use Carp;
use List::Util qw(min max);

my @uniq;
my @move_left;
my @move_right;
my @chaos;

sub diff {
	my ($big, $small) = @_;
	return $small ? $big - $small : 0;
}

sub chaos {
	my ($a, $b, $c, $d) = @_;
	($a, $b, $c, $d) = ($d, $c, $b, $a) if $a < $d;
	if ($a < $b || $a < $c) {
		return diff $c + $b, $a if $b == $c;
		return diff $b, max($a, $c + $d) if $b > $c;
		return diff $c, $b + $a;
	}
	return ($b == $a || $b == $d) && $d > $c ? diff $d, $c : 0 if $b >= $c && $b >= $d;
	return diff $c + ($d == $c ? $d : 0), $b if $c >= $d;
	return diff $d, $c + $b if $d == $a;
	# handle case when exactly one of $c and $b is 0 ?
	return diff $d, 2 * max($c, $b);
}

for my $i (0..0xFFFF) {
	@_ = map {($i >> $_) & 0xF} 12, 8, 4, 0;
	my ($a, $b, $c, $d) = map {$_ ? 1 << $_ : 0} @_;

	$uniq[$i] = ($a ^ $b) | ($c ^ $d);

	my @left = ((grep {$_} @_), (grep {!$_} @_));
	for (0..2) {
		if ($left[$_] == $left[$_ + 1]) {
			$left[$_] = ($left[$_] + 1) % 16;
			$left[$_ + 1] = 0;
		}
	}
	@left = ((grep {$_} @left), (grep {!$_} @left));
	$move_left[$i] = $left[0] << 12 | $left[1] << 8 | $left[2] << 4 | $left[3];
	$chaos[$i] = chaos $a, $b, $c, $d;
}

sub print_array {
	my $name = shift;
	print "const u16 $name\[65536] = {\n";
	for (0..4095) {
		printf "\t" . "0x%04x, " x 15 . "0x%04x,\n", @_[16*$_..16*$_+15];
	}
	print "};\n";
}

$" = ',';
print "#include <stdint.h>";
print "const uint16_t uniq[65536] = {@uniq};";
print "const uint16_t chaos[65536] = {@chaos};";
print "const uint16_t move_left[65536] = {@move_left};";
