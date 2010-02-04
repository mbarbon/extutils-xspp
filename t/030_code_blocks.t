#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 6;

run_diff xsp_stdout => 'expected';

__DATA__

=== Function with custom code block
--- xsp_stdout
%module{Foo};
%package{Foo};

%name{boo} int foo(int a)
    %code{% RETVAL = a + 12; %};
--- expected
MODULE=Foo

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

%name{boo} int foo(int a)
    %cleanup{% free( it ); %};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
boo( a )
    int a
  CODE:
    try {
      RETVAL = foo( a );
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }
  OUTPUT: RETVAL
  CLEANUP:
     free( it ); 

=== Function with custom postcall block
--- xsp_stdout
%module{Foo};
%package{Foo};

int foo(int a)
    %postcall{% blub( a ); %};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
foo( a )
    int a
  CODE:
    try {
      RETVAL = foo( a );
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }
  POSTCALL:
     blub( a ); 
  OUTPUT: RETVAL

=== Void function with custom code block
--- xsp_stdout
%module{Foo};
%package{Foo};

%name{boo} void foo(int a)
    %code{% blub( a ); %};
--- expected
MODULE=Foo

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

%name{boo} void foo(int a)
    %code{% blub( a ); %}
    %cleanup{% free( it ); %};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

void
boo( a )
    int a
  CODE:
     blub( a ); 
  CLEANUP:
     free( it ); 

=== Void function with custom postcall block
--- xsp_stdout
%module{Foo};
%package{Foo};

void foo(int a)
    %postcall{% blub( a ); %};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

void
foo( a )
    int a
  CODE:
    try {
      foo( a );
    } catch (std::exception& e) {
      croak("Caught unhandled C++ exception: %s", e.what());
    } catch (...) {
      croak("Caught unhandled C++ exception of unknown type");
    }
  POSTCALL:
     blub( a ); 
