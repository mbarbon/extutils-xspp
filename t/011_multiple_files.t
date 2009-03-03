#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 3;

run_diff process => 'expected';

__DATA__

=== Basic file - stdout
--- process xsp_stdout
%module{Foo};
%package{Foo};

%typemap{int}{simple};

%file{foo.h};
{%
Some verbatim
text
%}
%file{-};

int foo( int a, int b, int c );
--- expected
MODULE=Foo PACKAGE=Foo


int
foo( a, b, c )
    int a
    int b
    int c

=== Basic file - external file
--- process xsp_file=foo.h
%module{Foo};
%package{Foo};

%typemap{int}{simple};

%file{foo.h};
%{
Some verbatim
text
%}
%file{-};

int foo( int a, int b, int c );
--- expected
Some verbatim
text

=== Basic file - processed external file
--- process xsp_file=foo.h
%module{Foo};
%package{Foo};

%typemap{int}{simple};

%file{foo.h};
int bar( int x );
%file{-};

int foo( int a, int b, int c );
--- expected
int
bar( x )
    int x
