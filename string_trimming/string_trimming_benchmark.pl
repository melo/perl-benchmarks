#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Benchmark qw(:all);
use String::Trim;
use String::Strip;

benchmark_string( "100 spaces",  join '', ' ' x 100, 'foo', ' ' x 100 );
benchmark_string( "5 spaces",  join '', ' ' x 5, 'foo', ' ' x 5 );


sub benchmark_string {
    my( $title, $string ) = @_;

    say "## $title";

    cmpthese(
    -2,
    { 
        'String::Trim' => sub { 
            my $trimmed = String::Trim::trim( $string );
        },
        's/^\s*|\s*$//g' => sub { 
            ( my $trimmed = $string ) =~ s/^\s*|\s*$//g;
        },
        'cucumber cuts' => sub {
            my $trimmed = $string;
            local $/;
            for $/ ( ' ', "\t", "\n" ) {
                    for( 1..2 ) { 1 while chomp $trimmed; $trimmed = reverse $trimmed; }
            }
            return $trimmed;
        },
        'String::Strip' => sub {
            my $trimmed = $string;
            StripLTSpace($trimmed);
            die unless $trimmed eq 'foo';
            return $trimmed;
        },
    }
    );
}
