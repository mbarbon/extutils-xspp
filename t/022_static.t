#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 1;

run_diff xsp_stdout => 'expected';

__DATA__

=== Method decorated with package_static
--- xsp_stdout
%module{Foo};

%typemap{Foo*}{simple};
%typemap{int}{simple};

class Foo
{
    package_static int foo(int a);
};
--- expected
MODULE=Foo PACKAGE=Foo

int
Foo::foo( a )
    int a
  CODE:
    RETVAL = Foo::foo( a );
  OUTPUT: RETVAL
