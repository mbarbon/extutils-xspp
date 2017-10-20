#!/usr/bin/perl -w

use lib 't/lib';
use XSP::Test;

run_diff xsp_stdout => 'expected';

__DATA__

=== Simple include files
--- xsp_stdout
%module{XspTest};
%package{Foo};

%include{t/files/typemap.xsp};
%include{t/files/include.xsp};
int bar(int y);
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

# trivial typemap


int
foo( int x )
  CODE:
    RETVAL = foo( x );
  OUTPUT: RETVAL

int
bar( int y )
  CODE:
    RETVAL = bar( y );
  OUTPUT: RETVAL
