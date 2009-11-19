#!/usr/bin/perl -w

use strict;
use warnings;
use lib 't/lib';
use if -d 'blib' => 'blib';

use Test::More tests => 2;
use Test::Differences;
use ExtUtils::XSpp::Driver;

unlink $_ foreach 't/files/foo.h';

my $driver = ExtUtils::XSpp::Driver->new
  ( typemaps   => [ 't/files/typemap.xsp' ],
    file       => 't/files/test1.xsp',
    );

open my $fh, '>', \my $out;

{
    local *STDOUT = $fh;
    $driver->process;
}

sub slurp($) {
    open my $fh, '<', $_[0]
      or die "Could not open file '$_[0]' for reading: $!";
    return join '', <$fh>;
}

eq_or_diff( $out, <<EOT, 'Output on stdout' );
MODULE=Foo::Bar::Baz
#include <foo.h>



MODULE=Foo::Bar::Baz PACKAGE=Foo::Bar::Baz::Buz


int
foo( a, b, c )
    int a
    int b
    int c

EOT

eq_or_diff( slurp 't/files/foo.h', <<EOT, 'Output on external file' );


/* header file */

int foo( int, int, int );


EOT
