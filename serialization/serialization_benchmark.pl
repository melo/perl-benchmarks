#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Benchmark qw(:all);
use Data::Dumper      ();
use Data::Dump        ();
use Storable          ();
use JSON::XS          ();
use Data::MessagePack ();

my $hash = {
  1 => {
    6 => [
      { nome           => "Gest\xE3o do Aprovisionamento",
        preco_final    => "79.92",
        preco_original => "99.90",
        url => "/Gestao_Comercial/L_Gestao_do_Aprovisionamento.html",
      },
    ],
  },
};

my $t;
cmpthese(
  -2,
  { 'dumper'       => sub { $t = Data::Dumper::Dumper($hash) },
    'pp'           => sub { $t = Data::Dump::dump($hash) },
    'storable'     => sub { $t = Storable::nfreeze($hash) },
    'json_xs'      => sub { $t = JSON::XS::encode_json($hash) },
    'data_msgpack' => sub { $t = Data::MessagePack->pack($hash) },
  }
);

## Darwin DogsHouse.lan 9.8.0 Darwin Kernel Version 9.8.0: Wed Jul 15 16:55:01 PDT 2009; root:xnu-1228.15.4~1/RELEASE_I386 i386
## 2.4 Ghz Quad Core 2
#
#                  Rate          pp      dumper   storable data_msgpack    json_xs
# pp             3078/s          --        -80%       -81%         -99%       -99%
# dumper        15603/s        407%          --        -5%         -94%       -95%
# storable      16443/s        434%          5%         --         -94%       -94%
# data_msgpack 271773/s       8730%       1642%      1553%           --        -6%
# json_xs      289616/s       9309%       1756%      1661%           7%         --


my $e1 = Data::Dumper::Dumper($hash);
my $e2 = Storable::nfreeze($hash);
my $e3 = JSON::XS::encode_json($hash);
my $e4 = Data::MessagePack->pack($hash);

cmpthese(
  -2,
  { 'eval'         => sub { $t = eval $e1 },
    'storable'     => sub { $t = Storable::thaw($e2) },
    'json_xs'      => sub { $t = JSON::XS::decode_json($e3) },
    'data_msgpack' => sub { $t = Data::MessagePack->unpack($e4) },
  }
);

## Darwin DogsHouse.lan 9.8.0 Darwin Kernel Version 9.8.0: Wed Jul 15 16:55:01 PDT 2009; root:xnu-1228.15.4~1/RELEASE_I386 i386
## 2.4 Ghz Quad Core 2
#
#                  Rate         eval     storable data_msgpack      json_xs
# eval          22550/s           --         -82%         -87%         -89%
# storable     125431/s         456%           --         -30%         -41%
# data_msgpack 177977/s         689%          42%           --         -17%
# json_xs      213608/s         847%          70%          20%           --
