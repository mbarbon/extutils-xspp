#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 8;

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

=== Renamed function
--- xsp_stdout
%module{Foo};

%typemap{int}{simple};
%typemap{Foo*}{simple};

class Foo
{
    %name{bar} int foo( int a );
};
--- expected
MODULE=Foo PACKAGE=Foo

int
Foo::bar( a )
    int a
  CODE:
    RETVAL = THIS->foo( a );
  OUTPUT: RETVAL

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

=== Renamed onstructor
--- xsp_stdout
%module{Foo};

%typemap{int}{simple};
%typemap{Foo*}{simple};

class Foo
{
    %name{newFoo} Foo( int a );
};
--- expected
MODULE=Foo PACKAGE=Foo

static Foo*
Foo::newFoo( a )
    int a
  CODE:
    RETVAL = new Foo( a );
  OUTPUT: RETVAL

=== Destructor
--- xsp_stdout
%module{Foo};

%typemap{int}{simple};
%typemap{Foo*}{simple};

class Foo
{
    ~Foo();
};
--- expected
MODULE=Foo PACKAGE=Foo

void
Foo::DESTROY()

=== Void function
--- xsp_stdout
%module{Foo};

%typemap{int}{simple};
%typemap{void}{simple};

class Foo
{
    void foo( int a );
};
--- expected
MODULE=Foo PACKAGE=Foo

void
Foo::foo( a )
    int a

=== No parameters
--- xsp_stdout
%module{Foo};

%typemap{void}{simple};

class Foo
{
    void foo();
};
--- expected
MODULE=Foo PACKAGE=Foo

void
Foo::foo()
