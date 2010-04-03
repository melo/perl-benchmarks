#!/usr/bin/env perl

use strict;
use warnings;
use Benchmark qw( cmpthese );
use UUID::Tiny qw( :std );
use Data::UUID;
use Data::UUID::LibUUID;

my $du = Data::UUID->new;

cmpthese(
  -2,
  { uuid_tiny_v1 => sub { create_uuid_as_string(UUID_V1, 'asdfgh') },
    uuid_tiny_3  => sub { create_uuid_as_string(UUID_V3, 'asdfgh') },
    uuid_tiny_4  => sub { create_uuid_as_string(UUID_V4, 'asdfgh') },
    uuid_tiny_5  => sub { create_uuid_as_string(UUID_V5, 'asdfgh') },
    
    data_uuid => sub { $du->create_str },

    data_uuid_libuuid => sub { new_uuid_string() },
  }
);
