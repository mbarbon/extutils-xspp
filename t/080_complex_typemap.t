#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 6;

run_diff xsp_stdout => 'expected';

__DATA__

=== Complex typemap, type rename
--- xsp_stdout
%module{Foo};

%typemap{int}{parsed}{
    %cpp_type{foobar};
};

class Foo
{
    int foo( int a, int b );
};
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo

foobar
Foo::foo( a, b )
    foobar a
    foobar b
  CODE:
    try {
      RETVAL = THIS->foo( a, b );
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL

=== Complex typemap, custom return value conversion, $2 = C++ retval, $c = call code
--- xsp_stdout
%module{Foo};

%typemap{int}{parsed}{
    %call_function_code{% $2 = fancy_conversion( $c ) %};
};

class Foo
{
    int foo( int a, int b );
};
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( a, b )
    int a
    int b
  CODE:
    try {
       RETVAL = fancy_conversion( THIS->foo( a, b ) ) ;
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL

=== Complex typemap, output code, $2 = C++ return val
--- xsp_stdout
%module{Foo};

%typemap{int}{parsed}{
    %output_code{% $1 = custom_code( $2 ) %};
};

class Foo
{
    int foo( int a, int b );
};
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( a, b )
    int a
    int b
  CODE:
    try {
      RETVAL = THIS->foo( a, b );
       ST(0) = custom_code( RETVAL ) ;
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL

=== Complex typemap, cleanup code, $1 = Perl, $2 = C++
--- xsp_stdout
%module{Foo};

%typemap{int}{parsed}{
    %cleanup_code{% custom_code( $1, $2 ) %};
};

class Foo
{
    int foo( int a, int b );
};
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( a, b )
    int a
    int b
  CODE:
    try {
      RETVAL = THIS->foo( a, b );
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL
  CLEANUP:
     custom_code( ST(0), RETVAL ) ;

=== Complex typemap, pre-call code, $1 = Perl, $2 = C++
--- xsp_stdout
%module{Foo};

%typemap{int}{parsed}{
    %precall_code{% custom_code( $1, $2 ) %};
};

class Foo
{
    int foo( int a, int b );
};
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( a, b )
    int a
    int b
  CODE:
    try {
       custom_code( ST(1), a ) ;
 custom_code( ST(2), b ) ;
      RETVAL = THIS->foo( a, b );
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL

=== Complex typemap, output list code, $2 = C++ retval
--- xsp_stdout
%module{Foo};

%typemap{int}{parsed}{
    %output_list{% PUTBACK; XPUSHi( $2 ); SPAGAIN %};
};

class Foo
{
    int foo( int a, int b );
};
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( a, b )
    int a
    int b
  PPCODE:
    try {
      RETVAL = THIS->foo( a, b );
       PUTBACK; XPUSHi( RETVAL ); SPAGAIN ;
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
