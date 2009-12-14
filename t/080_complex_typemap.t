#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 5;

run_diff xsp_stdout => 'expected';

__DATA__

=== Complex typemap, type rename
--- xsp_stdout
%module{Foo};

%typemap{int}{parsed}{%foobar%};

class Foo
{
    int foo( int a, int b );
};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

foobar
Foo::foo( a, b )
    foobar a
    foobar b

=== Complex typemap, custom return value conversion
--- xsp_stdout
%module{Foo};

%typemap{int}{parsed}{%int%}{% $$ = fancy_conversion( $1 ) %};

class Foo
{
    int foo( int a, int b );
};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( a, b )
    int a
    int b
  CODE:
     RETVAL = fancy_conversion( THIS->foo( a, b ) ) ;
  OUTPUT: RETVAL

=== Complex typemap, output code
--- xsp_stdout
%module{Foo};

%typemap{int}{parsed}{%int%}{%%}{% custom_code( RETVAL ) %};

class Foo
{
    int foo( int a, int b );
};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( a, b )
    int a
    int b
  CODE:
    RETVAL = THIS->foo( a, b );
     custom_code( RETVAL ) ;
  OUTPUT: RETVAL

=== Complex typemap, cleanup code
--- xsp_stdout
%module{Foo};

%typemap{int}{parsed}{%int%}{%%}{%%}{% custom_code( ST(0), RETVAL ) %};

class Foo
{
    int foo( int a, int b );
};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( a, b )
    int a
    int b
  CODE:
    RETVAL = THIS->foo( a, b );
  OUTPUT: RETVAL
  CLEANUP:
     custom_code( ST(0), RETVAL ) ;

=== Complex typemap, pre-call code
--- xsp_stdout
%module{Foo};

%typemap{int}{parsed}{%int%}{%%}{%%}{%%}
    {% custom_code( $1, RETVAL ) %};

class Foo
{
    int foo( int a, int b );
};
--- expected
MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( a, b )
    int a
    int b
  CODE:
     custom_code( ST(1), RETVAL ) ;
 custom_code( ST(2), RETVAL ) ;
    RETVAL = THIS->foo( a, b );
  OUTPUT: RETVAL
