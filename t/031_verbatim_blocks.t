#!/usr/bin/perl -w

use t::lib::XSP::Test;

run_diff xsp_stdout => 'expected';

__DATA__

=== Verbatim blocks
--- xsp_stdout
%module{XspTest};
%package{Foo};

%{
Straight to XS, no checks...
%}
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo


Straight to XS, no checks...

=== Space after verbatim blocks
--- xsp_stdout
%module{XspTest};

class X
{
%{
Straight to XS, no checks...
%}
    int foo(int a);
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=X


Straight to XS, no checks...


int
X::foo( int a )
  CODE:
    RETVAL = THIS->foo( a );
  OUTPUT: RETVAL

