#!/usr/bin/env perl
use strict;
use warnings;
use Benchmark qw(cmpthese);
use Test::More;
use v5.10.0;

my @list = map rand(), 1..100_000;

my $expr_output;
my $expr = sub {
    $expr_output = [map $_>0.5, @list];
};

my $block_output;
my $block = sub {
    $block_output = [map { $_>0.5} @list];
};

cmpthese( -2, { EXPR => $expr, BLOCK => $block });

isa_ok $expr_output      => 'ARRAY';
isa_ok $block_output     => 'ARRAY';
is scalar @$expr_output  => 100_000;
is scalar @$block_output => 100_000;
done_testing;
