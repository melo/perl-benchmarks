#!/usr/bin/env perl
use strict;
use warnings;
use Benchmark qw(cmpthese);

my %hash_empty = ();
my %hash_small = (1..6);
my %hash_large = (1..10000);

foreach my $ref (\%hash_empty, \%hash_small, \%hash_large) {
  print 'hash size: ' . scalar(keys(%$ref)) . "\n";
  cmpthese(0, {
    if              => sub { if (%$ref)                 { 1 } else { 0 } },
    if_scalar       => sub { if (scalar %$ref)          { 1 } else { 0 } },
    if_keys         => sub { if (keys %$ref)            { 1 } else { 0 } },
    if_values       => sub { if (values %$ref)          { 1 } else { 0 } },
    if_scalar_keys  => sub { if (scalar keys %$ref)     { 1 } else { 0 } },
    if_scalar_keys  => sub { if (scalar keys %$ref)     { 1 } else { 0 } },
    if_scalar_values=> sub { if (scalar values %$ref)   { 1 } else { 0 } },
    if_each         => sub { if (each %$ref)            { 1 } else { 0 } },
    if_array_cast   => sub { my @a = %$ref; if (@a)     { 1 } else { 0 } },
  });
}
