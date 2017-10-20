#!/usr/bin/perl -w

use lib 't/lib';
use XSP::Test;

run_diff xsp_stdout => 'expected';

__DATA__

=== Reference in argument
--- xsp_stdout
%module{XspTest};

class Foo
{
    void foo( Foo& a );
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

void
Foo::foo( Foo* a )
  CODE:
    THIS->foo( *( a ) );

=== Reference in return value
--- xsp_stdout
%module{XspTest};

class Foo
{
    Foo& foo();
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

Foo*
Foo::foo()
  CODE:
    RETVAL = new Foo( THIS->foo() );
  OUTPUT: RETVAL

