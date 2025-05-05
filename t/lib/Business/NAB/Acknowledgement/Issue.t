#!/usr/bin/env perl

use strict;
use warnings;

use DateTime;
use Test::Most;
use FindBin qw/ $Bin /;
use File::Temp;
use Test::File::Contents;
use Test::Warnings;

my $class = join(
    '::',
    qw/
        Business
        NAB
        Acknowledgement
        Issue
        /,
);

use_ok( $class );

subtest 'instantiation' => sub {

    isa_ok(
        my $Issue = $class->new( code => 1, detail => 'foo' ),
        $class,
    );

    subtest 'attributes' => sub {
        is( $Issue->code,   1,     '->code' );
        is( $Issue->detail, 'foo', '->detail' );
    };
};

done_testing();
