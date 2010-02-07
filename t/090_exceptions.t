#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 4;

run_diff xsp_stdout => 'expected';

__DATA__

=== Basic exception declaration
--- xsp_stdout
%module{Foo};

%exception{myException}{std::exception}{stdmessage};

int foo(int a);

--- expected
MODULE=Foo
int
foo( a )
    int a
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
=== Basic exception declaration and catch
--- xsp_stdout
%module{Foo};

%exception{myException}{SomeException}{stdmessage};

int foo(int a)
  %catch{myException};

--- expected
MODULE=Foo
int
foo( a )
    int a
  CODE:
    try {
      RETVAL = foo( a );
    }
    catch (SomeException& e) {
      croak("Caught C++ exception of type or derived from 'SomeException': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL

=== Multiple exception declaration and catch
--- xsp_stdout
%module{Foo};

%exception{myException}{SomeException}{stdmessage};
%exception{myException2}{SomeException2}{simple};
%exception{myException3}{SomeException3}{simple};

int foo(int a)
  %catch{myException};

class Foo {
  int bar(int a)
    %catch{myException}
    %catch{myException2};

  int baz(int a)
    %catch{myException3}
    %catch{myException}
    %catch{myException2};

  int buz(int a)
    %catch{myException3};
};

--- expected
MODULE=Foo
int
foo( a )
    int a
  CODE:
    try {
      RETVAL = foo( a );
    }
    catch (SomeException& e) {
      croak("Caught C++ exception of type or derived from 'SomeException': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL


MODULE=Foo PACKAGE=Foo

int
Foo::bar( a )
    int a
  CODE:
    try {
      RETVAL = THIS->bar( a );
    }
    catch (SomeException& e) {
      croak("Caught C++ exception of type or derived from 'SomeException': %s", e.what());
    }
    catch (SomeException2& e) {
      croak("Caught C++ exception of type 'SomeException2'");
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL

int
Foo::baz( a )
    int a
  CODE:
    try {
      RETVAL = THIS->baz( a );
    }
    catch (SomeException3& e) {
      croak("Caught C++ exception of type 'SomeException3'");
    }
    catch (SomeException& e) {
      croak("Caught C++ exception of type or derived from 'SomeException': %s", e.what());
    }
    catch (SomeException2& e) {
      croak("Caught C++ exception of type 'SomeException2'");
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL

int
Foo::buz( a )
    int a
  CODE:
    try {
      RETVAL = THIS->buz( a );
    }
    catch (SomeException3& e) {
      croak("Caught C++ exception of type 'SomeException3'");
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL

=== 'code' exception
--- xsp_stdout
%module{Foo};

%exception{myException}{SomeException}{code}{% croak(e.what()); %};

int foo(int a)
  %catch{myException};

--- expected
MODULE=Foo
int
foo( a )
    int a
  CODE:
    try {
      RETVAL = foo( a );
    }
    catch (SomeException& e) {
      croak(e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL

