#!/usr/bin/perl -w

use lib 't/lib';
use XSP::Test;

run_diff xsp_stdout => 'expected';

__DATA__

=== Functions/methods with aTHX/aTHX_ argument
--- xsp_stdout
%module{XspTest};

class Foo
{
    int foo(aTHX_ int a);
    int bar(aTHX);
    int baz(aTHX, int a);
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

int
Foo::foo( int a )
  CODE:
    RETVAL = THIS->foo( aTHX_ a );
  OUTPUT: RETVAL

int
Foo::bar()
  CODE:
    RETVAL = THIS->bar( aTHX );
  OUTPUT: RETVAL

int
Foo::baz( int a )
  CODE:
    RETVAL = THIS->baz( aTHX_ a );
  OUTPUT: RETVAL
--- typemap
Foo *   T_PTRREF
--- preamble
struct Foo {
    int foo(aTHX_ int a) { return a + 2; }
    int bar(aTHX) { return 7; }
    int baz(aTHX_ int a) { return a + 1; }
};
