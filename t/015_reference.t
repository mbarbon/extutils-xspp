#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 2;

run_diff xsp_stdout => 'expected';

__DATA__

=== Reference in argument
--- xsp_stdout
%module{Foo};

class Foo
{
    void foo( Foo& a );
};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

void
Foo::foo( a )
    Foo* a
  CODE:
    THIS->foo( *( a ) );

=== Reference in return value
--- xsp_stdout
%module{Foo};

class Foo
{
    Foo& foo();
};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

Foo*
Foo::foo()
  CODE:
    RETVAL = new Foo( THIS->foo() );
  OUTPUT: RETVAL

