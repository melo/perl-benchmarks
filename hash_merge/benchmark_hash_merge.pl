#!/usr/bin/env perl

use strict;
use warnings;
use Benchmark 'cmpthese';
use Test::More;
use Test::Deep;


sub setup {
  my $source = { a => 1, b => 2, c => 3 };
  my @dest = (b => 3, d => 4);

  return ($source, @dest);
}

my $var_merge_output;
my $var_merge = sub {
  my ($source, @dest) = setup();

  %$source = (%$source, @dest);
  $var_merge_output = $source;
};

my $splice_output;
my $splice = sub {
  my ($source, @dest) = setup();

  while (@dest) {
    my ($k, $v) = splice(@dest, 0, 2);
    $source->{$k} = $v;
  }
  $splice_output = $source;
};

my $keys_output;
my $keys = sub {
  my ($source, %dest) = setup();

  for my $k (keys %dest) {
    $source->{$k} = $dest{$k};
  }
  $keys_output = $source;
};

my $iter_output;
my $iter = sub {
  my ($source, @dest) = setup();

  for(my $i = 0; $i < $#dest; $i += 2) {
    $source->{$dest[$i]} = $dest[$i+1];
  }
  $iter_output = $source;
};


cmpthese(
  -2,
  { using_var_merge => $var_merge,
    using_splice    => $splice,
    using_keys      => $keys,
    using_iter      => $iter,
  }
);


cmp_deeply($var_merge_output, $splice_output, 'var_merge, same result as splice_output');
cmp_deeply($var_merge_output, $keys_output,   'var_merge, same result as keys');
cmp_deeply($var_merge_output, $iter_output,   'var_merge, same result as iter');

done_testing();
