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
    int foo( int a, int b, int c );
};
--- expected
MODULE=Foo PACKAGE=Foo

int
Foo::foo( a, b, c )
    int a
    int b
    int c

=== Basic function
--- xsp_stdout
%module{Foo};
%package{Foo::Bar};

%typemap{int}{simple};

int foo( int a );
--- expected
MODULE=Foo PACKAGE=Foo::Bar

int
foo( a )
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

=== Comments and raw blocks
--- xsp_stdout
%module{Foo};

{%
  Passed through verbatim
  as written in sources
%}

# simple typemaps
%typemap{int}{simple};
%typemap{Foo*}{simple};

# before class
class Foo
{
    # before method
    int foo( int a, int b, int c );
    # after method
};
--- expected
  Passed through verbatim
  as written in sources
# simple typemaps
# before class
MODULE=Foo PACKAGE=Foo

# before method
int
Foo::foo( a, b, c )
    int a
    int b
    int c

# after method
