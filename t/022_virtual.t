#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 2;

run_diff xsp_stdout => 'expected';

__DATA__

=== Virtual method
--- xsp_stdout
%module{Foo};

class Foo
{
    virtual int foo(int a)
        %code{%dummy%};
    %name{bar} virtual int foo(int a) const
        %code{%dummy%};
};
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( a )
    int a
  CODE:
    dummy
  OUTPUT: RETVAL

int
Foo::bar( a )
    int a
  CODE:
    dummy
  OUTPUT: RETVAL

=== Pure-virtual method
--- xsp_stdout
%module{Foo};

class Foo
{
    virtual int foo(int a) = 0
        %code{%dummy%};
    %name{bar} virtual int foo(int a) const = 0
        %code{%dummy%};
};
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( a )
    int a
  CODE:
    dummy
  OUTPUT: RETVAL

int
Foo::bar( a )
    int a
  CODE:
    dummy
  OUTPUT: RETVAL
