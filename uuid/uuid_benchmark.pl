#!/usr/bin/env perl

use strict;
use warnings;
use Benchmark qw( cmpthese );

my %bench;

load_module(
  'UUID::Tiny',
  sub {
    UUID::Tiny->import(qw( :std ));

    $bench{uuid_tiny_3} = sub { create_uuid_as_string($UUID::Tiny::UUID_V3, $$) };
    $bench{uuid_tiny_3_bin} = sub { create_uuid($UUID::Tiny::UUID_V3, $$) };
    $bench{uuid_tiny_4}     = sub { create_uuid_as_string($UUID::Tiny::UUID_V4) };
    $bench{uuid_tiny_4_bin} = sub { create_uuid($UUID::Tiny::UUID_V4) };
    $bench{uuid_tiny_5}     = sub { create_uuid_as_string($UUID::Tiny::UUID_V5, $$) };
    $bench{uuid_tiny_5_bin} = sub { create_uuid($UUID::Tiny::UUID_V5, $$) };
  }
);

load_module(
  'Data::UUID',
  sub {
    my $du = Data::UUID->new;

    $bench{data_uuid_3}     = sub { $du->create_str };
    $bench{data_uuid_3_bin} = sub { $du->create_bin };
  }
);

load_module(
  'Data::UUID::LibUUID',
  sub {
    Data::UUID::LibUUID->import;

    $bench{data_uuid_libuuid_2}     = sub { new_uuid_string(2) };
    $bench{data_uuid_libuuid_2_bin} = sub { new_uuid_binary(2) };
    $bench{data_uuid_libuuid_4}     = sub { new_uuid_string(4) };
    $bench{data_uuid_libuuid_4_bin} = sub { new_uuid_binary(4) };
  }
);

load_module(
  'Data::UUID::MT',
  sub {
    my $mt  = Data::UUID::MT->new;
    my $mtn = $mt->iterator;

    $bench{data_uuid_mt_4}     = sub { $mt->create_string };
    $bench{data_uuid_mt_4_bin} = sub { $mtn->() };
  }
);

cmpthese(-2, \%bench);


sub load_module {
  my ($m, $cb) = @_;

  eval "require $m";
  if ($@) {
    print "Removing $m from benchmark, failed to load\n";
  }
  else {
    $cb->();
  }
  return;
}
