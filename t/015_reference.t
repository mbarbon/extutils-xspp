#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 2;

run_diff xsp_stdout => 'expected';

__DATA__

=== Reference in argument
--- xsp_stdout
%module{Foo};

class Foo
{
    void foo( Foo& a );
};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

void
Foo::foo( a )
    Foo* a
  CODE:
    try {
      THIS->foo( *( a ) );
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }

=== Reference in return value
--- xsp_stdout
%module{Foo};

class Foo
{
    Foo& foo();
};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

Foo*
Foo::foo()
  CODE:
    try {
      RETVAL = new Foo( THIS->foo() );
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }
  OUTPUT: RETVAL

