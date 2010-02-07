#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 2;

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
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
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
    } catch (SomeException& e) {
      croak("Caught C++ exception of type 'SomeException': %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }
  OUTPUT: RETVAL
