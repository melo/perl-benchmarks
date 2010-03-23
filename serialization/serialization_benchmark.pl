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
