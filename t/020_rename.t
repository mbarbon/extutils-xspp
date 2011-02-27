#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 5;

run_diff xsp_stdout => 'expected';

__DATA__

=== Renamed function (also in different package)
--- xsp_stdout
%module{Foo};
%package{Foo::Bar};

%name{boo} int foo(int a);
%name{moo::boo} int foo(int a);
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo::Bar

int
boo( int a )
  CODE:
    try {
      RETVAL = foo( a );
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL

MODULE=Foo PACKAGE=moo

int
boo( int a )
  CODE:
    try {
      RETVAL = foo( a );
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL

=== Renamed method
--- xsp_stdout
%module{Foo};

class Foo
{
    %name{bar} int foo( int a );
};
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::bar( int a )
  CODE:
    try {
      RETVAL = THIS->foo( a );
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL

=== Renamed constructor
--- xsp_stdout
%module{Foo};

class Foo
{
    %name{newFoo} Foo( int a );
};
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo

static Foo*
Foo::newFoo( int a )
  CODE:
    try {
      RETVAL = new Foo( a );
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL

=== Renamed destructor
--- xsp_stdout
%module{Foo};

class Foo
{
    %name{destroy} ~Foo();
};
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo

void
Foo::destroy()
  CODE:
    try {
      delete THIS;
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }

=== Renamed class
--- xsp_stdout
%module{Foo};

%name{Bar::Baz} class Foo
{
    void foo();
    %name{foo_int} int foo( int a );
};
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Bar::Baz

void
Foo::foo()
  CODE:
    try {
      THIS->foo();
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }

int
Foo::foo_int( int a )
  CODE:
    try {
      RETVAL = THIS->foo( a );
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL
