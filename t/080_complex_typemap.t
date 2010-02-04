#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 5;

run_diff xsp_stdout => 'expected';

__DATA__

=== Complex typemap, type rename
--- xsp_stdout
%module{Foo};

%typemap{int}{parsed}{%foobar%};

class Foo
{
    int foo( int a, int b );
};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

foobar
Foo::foo( a, b )
    foobar a
    foobar b
  CODE:
    try {
      RETVAL = THIS->foo( a, b );
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }
  OUTPUT: RETVAL

=== Complex typemap, custom return value conversion
--- xsp_stdout
%module{Foo};

%typemap{int}{parsed}{%int%}{% $$ = fancy_conversion( $1 ) %};

class Foo
{
    int foo( int a, int b );
};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( a, b )
    int a
    int b
  CODE:
    try {
       RETVAL = fancy_conversion( THIS->foo( a, b ) ) ;
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }
  OUTPUT: RETVAL

=== Complex typemap, output code
--- xsp_stdout
%module{Foo};

%typemap{int}{parsed}{%int%}{%%}{% custom_code( RETVAL ) %};

class Foo
{
    int foo( int a, int b );
};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( a, b )
    int a
    int b
  CODE:
    try {
      RETVAL = THIS->foo( a, b );
       custom_code( RETVAL ) ;
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }
  OUTPUT: RETVAL

=== Complex typemap, cleanup code
--- xsp_stdout
%module{Foo};

%typemap{int}{parsed}{%int%}{%%}{%%}{% custom_code( ST(0), RETVAL ) %};

class Foo
{
    int foo( int a, int b );
};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( a, b )
    int a
    int b
  CODE:
    try {
      RETVAL = THIS->foo( a, b );
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }
  OUTPUT: RETVAL
  CLEANUP:
     custom_code( ST(0), RETVAL ) ;

=== Complex typemap, pre-call code
--- xsp_stdout
%module{Foo};

%typemap{int}{parsed}{%int%}{%%}{%%}{%%}
    {% custom_code( $1, RETVAL ) %};

class Foo
{
    int foo( int a, int b );
};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( a, b )
    int a
    int b
  CODE:
    try {
       custom_code( ST(1), RETVAL ) ;
 custom_code( ST(2), RETVAL ) ;
      RETVAL = THIS->foo( a, b );
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }
  OUTPUT: RETVAL
