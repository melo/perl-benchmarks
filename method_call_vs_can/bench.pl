#!/usr/bin/env perl

use strict;
use warnings;
use Benchmark 'cmpthese';

package X;

sub x {}

package main;


cmpthese(-3, {
    'can filter'  => sub { X->y() if X->can('y') },
    'method call' => sub { X->x()                },
});

__END__

                   Rate  can filter method call
  can filter  1882989/s          --        -24%
  method call 2482460/s         32%          --
