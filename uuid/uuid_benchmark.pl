#!/usr/bin/env perl

use strict;
use warnings;
use Benchmark qw( cmpthese );
use UUID::Tiny qw( :std );
use Data::UUID;
use Data::UUID::LibUUID;
use Data::UUID::MT;

my $du  = Data::UUID->new;
my $mt  = Data::UUID::MT->new;
my $mtn = $mt->iterator;

cmpthese(
  -2,
  { uuid_tiny_3     => sub { create_uuid_as_string(UUID_V3, $$) },
    uuid_tiny_3_bin => sub { create_uuid(UUID_V3, $$) },
    uuid_tiny_4     => sub { create_uuid_as_string(UUID_V4) },
    uuid_tiny_4_bin => sub { create_uuid(UUID_V4) },
    uuid_tiny_5     => sub { create_uuid_as_string(UUID_V5, $$) },
    uuid_tiny_5_bin => sub { create_uuid(UUID_V5, $$) },

    data_uuid_3     => sub { $du->create_str },
    data_uuid_3_bin => sub { $du->create_bin },

    data_uuid_libuuid_2     => sub { new_uuid_string(2) },
    data_uuid_libuuid_2_bin => sub { new_uuid_binary(2) },
    data_uuid_libuuid_4     => sub { new_uuid_string(4) },
    data_uuid_libuuid_4_bin => sub { new_uuid_binary(4) },

    data_uuid_mt_4     => sub { $mt->create_string },
    data_uuid_mt_4_bin => sub { $mtn->() },
  }
);
