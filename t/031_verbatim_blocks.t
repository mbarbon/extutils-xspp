#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 2;

run_diff xsp_stdout => 'expected';

__DATA__

=== Verbatim blocks
--- xsp_stdout
%module{Foo};
%package{Foo};

%{
Straight to XS, no checks...
%}
--- expected
MODULE=Foo PACKAGE=Foo


Straight to XS, no checks...

=== Space after verbatim blocks
--- xsp_stdout
%module{Foo};
%typemap{int}{simple};

class X
{
%{
Straight to XS, no checks...
%}
    int foo(int a);
};
--- expected
MODULE=Foo PACKAGE=X


Straight to XS, no checks...


int
X::foo( a )
    int a
