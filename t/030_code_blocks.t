#!/usr/bin/perl -w

use lib 't/lib';
use XSP::Test;

run_diff xsp_stdout => 'expected';

__DATA__

=== Function with custom code block
--- xsp_stdout
%module{XspTest};
%package{Foo};

%name{boo} int foo(int a)
    %code{% RETVAL = a + 12; %};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

int
boo( int a )
  CODE:
     RETVAL = a + 12; 
  OUTPUT: RETVAL

=== Function with custom cleanup block
--- xsp_stdout
%module{XspTest};
%package{Foo};

%name{boo} int foo(int a)
    %cleanup{% free( it ); %};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

int
boo( int a )
  CODE:
    RETVAL = foo( a );
  OUTPUT: RETVAL
  CLEANUP:
     free( it ); 

=== Function with custom postcall block
--- xsp_stdout
%module{XspTest};
%package{Foo};

int foo(int a)
    %postcall{% blub( a ); %};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

int
foo( int a )
  CODE:
    RETVAL = foo( a );
  POSTCALL:
     blub( a ); 
  OUTPUT: RETVAL

=== Void function with custom code block
--- xsp_stdout
%module{XspTest};
%package{Foo};

%name{boo} void foo(int a)
    %code{% blub( a ); %};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

void
boo( int a )
  CODE:
     blub( a ); 

=== Void function with custom code and cleanup blocks
--- xsp_stdout
%module{XspTest};
%package{Foo};

%name{boo} void foo(int a)
    %code{% blub( a ); %}
    %cleanup{% free( it ); %};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

void
boo( int a )
  CODE:
     blub( a ); 
  CLEANUP:
     free( it ); 

=== Void function with custom postcall block
--- xsp_stdout
%module{XspTest};
%package{Foo};

void foo(int a)
    %postcall{% blub( a ); %};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

void
foo( int a )
  CODE:
    foo( a );
  POSTCALL:
     blub( a ); 
