#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 2;

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
%typemap{void}{simple};

void foo(const std::string a);
void boo(const std::string& a);
--- expected
MODULE=Foo PACKAGE=Foo

void
foo( a )
    const std::string a

void
boo( a )
    std::string* a
  CODE:
    boo( *( a ) );
