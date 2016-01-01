#!/usr/bin/perl -w

use t::lib::XSP::Test;

run_diff xsp_stdout => 'expected';

# tests for %name{} and %alias{}

__DATA__

=== Renamed function (also in different package)
--- xsp_stdout
%module{XspTest};
%package{Foo::Bar};

%name{boo} int foo(int a);
%name{moo::boo} int foo(int a);
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo::Bar

int
boo( int a )
  CODE:
    RETVAL = foo( a );
  OUTPUT: RETVAL

MODULE=XspTest PACKAGE=moo

int
boo( int a )
  CODE:
    RETVAL = foo( a );
  OUTPUT: RETVAL

=== Function with alias
--- xsp_stdout
%module{XspTest};
%package{Foo::Bar};

%name{boo} int foo2(int a) %alias{baz2 = 3};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo::Bar

int
boo( int a )
  ALIAS:
    baz2 = 3
  CODE:
    if (ix == 0) {
        RETVAL = foo2( a );
      }
      else if (ix == 3) {
        RETVAL = baz2( a );
      }
      else
        croak("Panic: Invalid invocation of function alias number %i!", (int)ix));
  OUTPUT: RETVAL

=== Function with alias and code
--- xsp_stdout
%module{XspTest};
%package{Foo::Bar};

%name{boo} int foo2(int a) %alias{baz2 = 3} %code{%RETVAL = a;%};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo::Bar

int
boo( int a )
  ALIAS:
    baz2 = 3
  CODE:
    RETVAL = a;
  OUTPUT: RETVAL

=== Function with multiple aliases
--- xsp_stdout
%module{XspTest};
%package{Foo::Bar};

%name{boo} int foo2(int a) %alias{baz2 = 3} %alias{buz2 = 1};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo::Bar

int
boo( int a )
  ALIAS:
    buz2 = 1
    baz2 = 3
  CODE:
    if (ix == 0) {
        RETVAL = foo2( a );
      }
      else if (ix == 1) {
        RETVAL = buz2( a );
      }
      else if (ix == 3) {
        RETVAL = baz2( a );
      }
      else
        croak("Panic: Invalid invocation of function alias number %i!", (int)ix));
  OUTPUT: RETVAL

=== Renamed method
--- xsp_stdout
%module{XspTest};

class Foo
{
    %name{bar} int foo( int a );
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

int
Foo::bar( int a )
  CODE:
    RETVAL = THIS->foo( a );
  OUTPUT: RETVAL

=== Renamed method with alias
--- xsp_stdout
%module{XspTest};

class Foo
{
    %name{bar} int foo( int a ) %alias{baz = 1};
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

int
Foo::bar( int a )
  ALIAS:
    baz = 1
  CODE:
    if (ix == 0) {
        RETVAL = THIS->foo( a );
      }
      else if (ix == 1) {
        RETVAL = THIS->baz( a );
      }
      else
        croak("Panic: Invalid invocation of function alias number %i!", (int)ix));
  OUTPUT: RETVAL

=== Renamed constructor
--- xsp_stdout
%module{XspTest};

class Foo
{
    %name{newFoo} Foo( int a );
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

#undef  xsp_constructor_class
#define xsp_constructor_class(c) (CLASS)

static Foo*
Foo::newFoo( int a )
  CODE:
    RETVAL = new Foo( a );
  OUTPUT: RETVAL

#undef  xsp_constructor_class
#define xsp_constructor_class(c) (c)

=== Renamed destructor
--- xsp_stdout
%module{XspTest};

class Foo
{
    %name{destroy} ~Foo();
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

void
Foo::destroy()
  CODE:
    delete THIS;

=== Renamed class
--- xsp_stdout
%module{XspTest};

%name{Bar::Baz} class Foo
{
    void foo();
    %name{foo_int} int foo( int a );
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Bar::Baz

void
Foo::foo()
  CODE:
    THIS->foo();

int
Foo::foo_int( int a )
  CODE:
    RETVAL = THIS->foo( a );
  OUTPUT: RETVAL
