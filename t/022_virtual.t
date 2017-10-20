#!/usr/bin/perl -w

use lib 't/lib';
use XSP::Test;

run_diff xsp_stdout => 'expected';

__DATA__

=== Virtual method
--- xsp_stdout
%module{XspTest};

class Foo
{
    virtual int foo(int a)
        %code{%dummy%};
    %name{bar} virtual int foo(int a) const
        %code{%dummy%};
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

int
Foo::foo( int a )
  CODE:
    dummy
  OUTPUT: RETVAL

int
Foo::bar( int a )
  CODE:
    dummy
  OUTPUT: RETVAL

=== Virtual destructor
--- xsp_stdout
%module{XspTest};

class Foo
{
    virtual ~Foo()
        %code{%dummy%};
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

void
Foo::DESTROY()
  CODE:
    dummy

=== Pure-virtual method
--- xsp_stdout
%module{XspTest};

class Foo
{
    virtual int foo(int a) = 0
        %code{%dummy%};
    %name{bar} virtual int foo(int a) const = 0
        %code{%dummy%};
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

int
Foo::foo( int a )
  CODE:
    dummy
  OUTPUT: RETVAL

int
Foo::bar( int a )
  CODE:
    dummy
  OUTPUT: RETVAL
