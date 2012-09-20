#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Benchmark qw(:all);
use String::Trim;
use String::Strip;

my %methods = (
    'String::Trim'  => \&string_trim,
    'cucumber_cuts' => \&cucumber,
    'String::Strip' => \&string_strip,
    'regex'         => \&regex,
);

benchmark_string( 
    "100 spaces",  
    join( '', ' ' x 100, 'foo', ' ' x 100  ),
    'foo'
);

benchmark_string( 
    "5 spaces",  
    join( '', ' ' x 5, 'foo', ' ' x 5 ),
    'foo'
);

benchmark_string( 
    "no space",  
    'foo',
    'foo'
);

sub string_trim { 
    return String::Trim::trim( shift );
}

sub regex { 
    my $string = shift;
    $string =~ s/^\s*|\s*$//g;
    return $string;
}

sub cucumber {
    my $string = shift;
    local $/;
    for my $x ( ' ', "\t", "\n" ) {
        $/ = $x;
        for( 1..2 ) { 1 while chomp $string; $string = reverse $string; }
    }
    return $string;
}

sub string_strip {
    my $string = shift;
    StripLTSpace($string);
    return $string;
}

sub benchmark_string {
    my( $title, $string, $result ) = @_;

    say "\n## $title";

    my %m = %methods;

    for ( keys %m ) {
        my $f = $m{$_};
        $m{$_} = sub { $f->($string) }
    }

    # sanity check
    if ( $result ) {
        while ( my ( $t, $m ) = each %m ) {
            my $r = $m->();
            die "$t returned $r, not $result" if $r ne $result;
        }
    }

    cmpthese( -2, \%m );
}
