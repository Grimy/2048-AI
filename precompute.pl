#!/usr/bin/perl -w

use strict;
use Carp;
use List::Util qw(min max);

my @uniq;
my @move_left;
my @move_right;
my @chaos;

sub diff {
	my ($big, $small) = @_;
	croak "$small > $big" if $small > $big;
	return $small ? $big - $small : 0;
}

sub chaos {
	my @sorted = sort {$b<=>$a} @_;
	my ($a, $b, $c, $d) = @_;
	($a, $b, $c, $d) = ($d, $c, $b, $a) if $a < $d;

	if ($a < $b || $a < $c) {
		if ($b == $c) {
			die unless $b == $sorted[0];
			return diff $c + $b, $a;
		}
		if ($b > $c) {
			die unless $b == $sorted[0];
			return diff $b, max($a, $c + $d);
		}
		die unless $c == $sorted[0];
		return diff $c, $b + $a;
	}
	die unless $a == $sorted[0];

	if ($b >= $c && $b >= $d) {
		die unless $b == $sorted[1];
		if ($b == $a || $b == $d) {
			return $d > $c ? diff $d, $c : 0;
		}
		return 0;
	}

	if ($c >= $d) {
		die unless $c == $sorted[1];
		return diff $c + ($d == $c ? $d : 0), $b;
	}

	die unless $d == $sorted[1];
	if ($d == $a) {
		return diff $d, $c + $b;
	}
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
			++$left[$_];
			$left[$_ + 1] = 0;
		}
	}
	@left = ((grep {$_} @left), (grep {!$_} @left));
	$move_left[$i] = $left[0] << 12 | $left[1] << 8 | $left[2] << 4 | $left[3];
	$chaos[$i] = chaos $a, $b, $c, $d;

	print "$a, $b, $c, $d: $chaos[$i]$/";
}
