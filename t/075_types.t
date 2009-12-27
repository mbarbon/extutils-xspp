#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 3;

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
MODULE=Foo

MODULE=Foo PACKAGE=Foo

int*
foo()

int*
boo( a )
    const int* a

=== Const value/const reference type
--- xsp_stdout
%module{Foo};
%package{Foo};

%typemap{const std::string}{simple};
%typemap{const std::string&}{reference};

void foo(const std::string a);
void boo(const std::string& a);
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

void
foo( a )
    const std::string a

void
boo( a )
    std::string* a
  CODE:
    boo( *( a ) );

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
MODULE=Foo

MODULE=Foo PACKAGE=Foo


void
foo( a )
    const std::vector< int >& a

void
boo( a )
    const std::map< int, std::string > a
