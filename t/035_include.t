#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 1;

run_diff xsp_stdout => 'expected';

__DATA__

=== Simple include files
--- xsp_stdout
%module{Foo};
%package{Foo};

%include{t/files/typemap.xsp};
%include{t/files/include.xsp};
int bar(int y);
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

# trivial typemap


int
foo( x )
    int x

int
bar( y )
    int y
