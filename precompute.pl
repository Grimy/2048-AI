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

sub move(&@) {
	my $sub = shift;
	@_ = ($sub->(grep {$_} @_), (grep {!$_} @_));
	for (grep {$_[$_] == $_[$_ + 1]} 0..2) {
		$_[$_] = ($_[$_] + 1) % 16;
		$_[$_ + 1] = 0;
	}
	@_ = $sub->((grep {$_} @_), (grep {!$_} @_));
	return $_[0] << 12 | $_[1] << 8 | $_[2] << 4 | $_[3];
}

for my $i (0..0xFFFF) {
	@_ = map {($i >> $_) & 0xF} 12, 8, 4, 0;
	my ($a, $b, $c, $d) = map {$_ ? 1 << $_ : 0} @_;

	$uniq[$i] = ($a ^ $b) | ($c ^ $d);
	$move_left[$i] = move {@_} @_;
	$move_right[$i] = move {reverse @_} @_;
	$chaos[$i] = chaos $a, $b, $c, $d;
}

local $" = ',';
print "#include <stdint.h>";
print "const uint16_t uniq[65536] = {@uniq};";
print "const uint16_t chaos[65536] = {@chaos};";
print "const uint16_t move_left[65536] = {@move_left};";
print "const uint16_t move_right[65536] = {@move_right};";
