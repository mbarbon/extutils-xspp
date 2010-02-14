#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 1;

run_diff xsp_stdout => 'expected';

__DATA__

=== Handle class/method/function annotations
--- xsp_stdout
%module{Foo};
%package{Foo};
%loadplugin{TestParserPlugin};

int foo(int y) %MyFuncRename{Foo};

class klass
{
    %MyClassRename{Klass};

    void bar() %MyMethodRename{Bar};
};
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo( y )
    int y
  CODE:
    try {
      RETVAL = foo( y );
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL


MODULE=Foo PACKAGE=Klass

void
klass::Bar()
  CODE:
    try {
      THIS->bar();
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
