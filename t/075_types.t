#!/usr/bin/perl -w

use lib 't/lib';
use XSP::Test;

run_diff xsp_stdout => 'expected';

__DATA__

=== Pointer/const pointer type
--- xsp_stdout
%module{XspTest};
%package{Foo};

%typemap{int*}{simple};
%typemap{const int*}{simple};

int* foo();
int* boo(const int* a);
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

int*
foo()
  CODE:
    RETVAL = foo();
  OUTPUT: RETVAL

int*
boo( const int* a )
  CODE:
    RETVAL = boo( a );
  OUTPUT: RETVAL

=== Const value/const reference type
--- xsp_stdout
%module{XspTest};
%package{Foo};

%typemap{const std::string}{simple};
%typemap{const std::string&}{reference};

void foo(const std::string a);
void boo(const std::string& a);
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

void
foo( const std::string a )
  CODE:
    foo( a );

void
boo( std::string* a )
  CODE:
    boo( *( a ) );

=== Const value/const reference type via shortcut
--- xsp_stdout
%module{XspTest};
%package{Foo};

%typemap{const std::string};
%typemap{std::vector<double>};

void foo(const std::string a);
void boo(const std::string& a);
void foo2(std::vector<double> a, std::vector<double>& b);
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

void
foo( const std::string a )
  CODE:
    foo( a );

void
boo( std::string* a )
  CODE:
    boo( *( a ) );

void
foo2( std::vector< double > a, std::vector< double >* b )
  CODE:
    foo2( a, *( b ) );


=== Template type
--- xsp_stdout
%module{XspTest};
%package{Foo};

%typemap{const std::vector<int>&}{simple};
%typemap{const std::map<int, std::string>}{simple};
%typemap{const std::vector&}{reference}; // check type equality

void foo(const std::vector<int>& a);
void boo(const std::map<int, std::string> a);
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo


void
foo( const std::vector< int >& a )
  CODE:
    foo( a );

void
boo( const std::map< int, std::string > a )
  CODE:
    boo( a );

=== Template argument transformed to pointer
--- xsp_stdout
%module{XspTest};
%package{Foo};

%typemap{const std::vector<double>&}{reference}; // check type equality

void foo(const std::vector<double>& a);
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo


void
foo( std::vector< double >* a )
  CODE:
    foo( *( a ) );
