#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 4;

run_diff xsp_stdout => 'expected';

__DATA__

=== Pointer/const pointer type
--- xsp_stdout
%module{Foo};
%package{Foo};

%typemap{int*}{simple};
%typemap{const int*}{simple};

int* foo();
int* boo(const int* a);
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo

int*
foo()
  CODE:
    try {
      RETVAL = foo();
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }
  OUTPUT: RETVAL

int*
boo( a )
    const int* a
  CODE:
    try {
      RETVAL = boo( a );
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }
  OUTPUT: RETVAL

=== Const value/const reference type
--- xsp_stdout
%module{Foo};
%package{Foo};

%typemap{const std::string}{simple};
%typemap{const std::string&}{reference};

void foo(const std::string a);
void boo(const std::string& a);
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo

void
foo( a )
    const std::string a
  CODE:
    try {
      foo( a );
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }

void
boo( a )
    std::string* a
  CODE:
    try {
      boo( *( a ) );
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }

=== Template type
--- xsp_stdout
%module{Foo};
%package{Foo};

%typemap{const std::vector<int>&}{simple};
%typemap{const std::map<int, std::string>}{simple};
%typemap{const std::vector&}{reference}; // check type equality

void foo(const std::vector<int>& a);
void boo(const std::map<int, std::string> a);
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo


void
foo( a )
    const std::vector< int >& a
  CODE:
    try {
      foo( a );
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }

void
boo( a )
    const std::map< int, std::string > a
  CODE:
    try {
      boo( a );
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }
=== Template argument transformed to pointer
--- xsp_stdout
%module{Foo};
%package{Foo};

%typemap{const std::vector<double>&}{reference}; // check type equality

void foo(const std::vector<double>& a);
--- expected
#include <exception>


MODULE=Foo

MODULE=Foo PACKAGE=Foo


void
foo( a )
    std::vector< double >* a
  CODE:
    try {
      foo( *( a ) );
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }
