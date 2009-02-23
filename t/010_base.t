#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 3;

run_diff xsp_stdout => 'expected';

__DATA__

=== Basic class
--- xsp_stdout
%module{Foo};

%typemap{int}{simple};
%typemap{Foo*}{simple};

class Foo
{
    int foo( int a );
};
--- expected
MODULE=Foo PACKAGE=Foo

int
Foo::foo( a )
    int a

=== Default arguments
--- xsp_stdout
%module{Foo};

%typemap{int}{simple};
%typemap{Foo*}{simple};

class Foo
{
    int foo( int a = 1 );
};
--- expected
MODULE=Foo PACKAGE=Foo

int
Foo::foo( a = 1 )
    int a

=== Constructor
--- xsp_stdout
%module{Foo};

%typemap{int}{simple};
%typemap{Foo*}{simple};

class Foo
{
    Foo( int a = 1 );
};
--- expected
MODULE=Foo PACKAGE=Foo

Foo*
Foo::new( a = 1 )
    int a
