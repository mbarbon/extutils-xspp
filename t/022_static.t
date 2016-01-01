#!/usr/bin/perl -w

use t::lib::XSP::Test;

run_diff xsp_stdout => 'expected';

__DATA__

=== Method decorated with package_static
--- xsp_stdout
%module{XspTest};

class Foo
{
    package_static int foo(int a);
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

int
foo( int a )
  CODE:
    RETVAL = Foo::foo( a );
  OUTPUT: RETVAL
