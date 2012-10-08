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
use Sereal::Encoder;
use Sereal::Decoder;

my $s_enc = Sereal::Encoder->new({no_shared_hashkeys => 1});
my $s_dec = Sereal::Decoder->new;

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

# NOTE: Modules like Data::Dumper inadvertently upgrade the data structure
#       that they are serializing. That means that subsequent serialization
#       with more sophisticated tools is going to be slowed down artificially.
#       Worse yet, it's dependend on the order in which things are benchmarked.
my $t;
cmpthese(
  -2,
  { 'dumper'       => sub { $t = Data::Dumper::Dumper($hash) },
    'pp'           => sub { $t = Data::Dump::dump($hash) },
    'storable'     => sub { $t = Storable::nfreeze($hash) },
    'json_xs'      => sub { $t = JSON::XS::encode_json($hash) },
    'data_msgpack' => sub { $t = Data::MessagePack->pack($hash) },
    'sereal      ' => sub { $t = $s_enc->encode($hash) },
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

## Linux l4tsee 3.0.0-23-generic #39-Ubuntu SMP Thu Jul 19 19:19:11 UTC 2012 x86_64 x86_64 x86_64 GNU/Linux
## Intel(R) Core(TM) i5 CPU       M 520  @ 2.40GHz
#                   Rate      pp dumper storable data_msgpack json_xs sereal
# pp              4419/s      --   -86%     -92%         -99%    -99%        -100%
# dumper         30916/s    600%     --     -45%         -90%    -95%         -97%
# storable       56659/s   1182%    83%       --         -82%    -91%         -94%
# data_msgpack  315789/s   7045%   921%     457%           --    -51%         -69%
# json_xs       645068/s  14496%  1987%    1039%         104%      --         -37%
# sereal       1029248/s  23189%  3229%    1717%         226%     60%           --


my $e1 = Data::Dumper::Dumper($hash);
my $e2 = Storable::nfreeze($hash);
my $e3 = JSON::XS::encode_json($hash);
my $e4 = Data::MessagePack->pack($hash);
my $e5 = $s_enc->encode($hash);

cmpthese(
  -2,
  { 'eval'         => sub { $t = eval $e1 },
    'storable'     => sub { $t = Storable::thaw($e2) },
    'json_xs'      => sub { $t = JSON::XS::decode_json($e3) },
    'data_msgpack' => sub { $t = Data::MessagePack->unpack($e4) },
    'sereal'       => sub { $t = $s_dec->decode($e5) },
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

## Linux l4tsee 3.0.0-23-generic #39-Ubuntu SMP Thu Jul 19 19:19:11 UTC 2012 x86_64 x86_64 x86_64 GNU/Linux
## Intel(R) Core(TM) i5 CPU       M 520  @ 2.40GHz
#                  Rate        eval   storable data_msgpack    json_xs      sereal
# eval          36540/s          --       -83%         -88%       -90%        -92%
# storable     209755/s        474%         --         -31%       -45%        -52%
# data_msgpack 302207/s        727%        44%           --       -20%        -31%
# json_xs      380075/s        940%        81%          26%         --        -13%
# sereal       434834/s       1090%       107%          44%        14%          --
