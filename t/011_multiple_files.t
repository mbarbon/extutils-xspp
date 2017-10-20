#!/usr/bin/perl -w

use lib 't/lib';
use XSP::Test;

run_diff process => 'expected';

__DATA__

=== Basic file - stdout
--- process xsp_stdout
%module{XspTest};
%package{Foo};

%file{foo.h};
{%
Some verbatim
text
%}
%file{-};

int foo( int a, int b, int c );
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

int
foo( int a, int b, int c )
  CODE:
    RETVAL = foo( a, b, c );
  OUTPUT: RETVAL

=== Basic file - external file
--- process xsp_file=foo.h
%module{XspTest};
%package{Foo};

%file{foo.h};
%{
Some verbatim
text
%}
%file{-};

int foo( int a, int b, int c );
--- expected
# XSP preamble



Some verbatim
text

=== Basic file - processed external file
--- process xsp_file=foo.h
%module{XspTest};
%package{Foo};

%file{foo.h};
int bar( int x );
%file{-};

int foo( int a, int b, int c );
--- expected
# XSP preamble


int
bar( int x )
  CODE:
    RETVAL = bar( x );
  OUTPUT: RETVAL
