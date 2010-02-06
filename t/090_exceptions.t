#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 1;

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
