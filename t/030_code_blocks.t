#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 4;

run_diff xsp_stdout => 'expected';

__DATA__

=== Function with custom code block
--- xsp_stdout
%module{Foo};
%package{Foo};
%typemap{int}{simple};

%name{boo} int foo(int a)
    %code{% RETVAL = a + 12; %};
--- expected
MODULE=Foo PACKAGE=Foo

int
boo( a )
    int a
  CODE:
     RETVAL = a + 12; 
  OUTPUT: RETVAL

=== Function with custom cleanup block
--- xsp_stdout
%module{Foo};
%package{Foo};
%typemap{int}{simple};

%name{boo} int foo(int a)
    %cleanup{% free( it ); %};
--- expected
MODULE=Foo PACKAGE=Foo

int
boo( a )
    int a
  CODE:
    RETVAL = foo( a );
  OUTPUT: RETVAL
  CLEANUP:
     free( it ); 

=== Void function with custom code block
--- xsp_stdout
%module{Foo};
%package{Foo};
%typemap{int}{simple};
%typemap{void}{simple};

%name{boo} void foo(int a)
    %code{% blub( a ); %};
--- expected
MODULE=Foo PACKAGE=Foo

void
boo( a )
    int a
  CODE:
     blub( a ); 

=== Void function with custom code and cleanup blocks
--- xsp_stdout
%module{Foo};
%package{Foo};
%typemap{int}{simple};
%typemap{void}{simple};

%name{boo} void foo(int a)
    %code{% blub( a ); %}
    %cleanup{% free( it ); %};
--- expected
MODULE=Foo PACKAGE=Foo

void
boo( a )
    int a
  CODE:
     blub( a ); 
  CLEANUP:
     free( it ); 
