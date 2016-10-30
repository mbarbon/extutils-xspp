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
    Foo *bar();
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

Foo*
Foo::bar()
  CODE:
    RETVAL = THIS->bar();
  OUTPUT: RETVAL

=== Renamed class with fixed return typemap handling
--- xsp_stdout
%loadplugin{feature::renamed_types_typemap};
%loadplugin{feature::default_xs_typemap};

%module{XspTest};

%name{Bar::Baz} class Foo
{
    Foo(int v);
    Foo *inc();
    int add(Foo *other);
    int add_int(int other);
};
--- expected
# XSP preamble


MODULE=XspTest
TYPEMAP: <<END
TYPEMAP
const Bar::Baz*	O_OBJECT
Bar::Baz*	O_OBJECT

END
MODULE=XspTest PACKAGE=Bar::Baz

# XSP preamble

Bar::Baz*
Bar::Baz::new( int v )
  PREINIT:
    typedef Foo Bar__Baz;
  CODE:
    RETVAL = new Foo( v );
  OUTPUT: RETVAL

# XSP preamble

Bar::Baz*
Bar::Baz::inc()
  PREINIT:
    typedef Foo Bar__Baz;
  CODE:
    RETVAL = THIS->inc();
  OUTPUT: RETVAL

int
Bar::Baz::add( Bar::Baz* other )
  PREINIT:
    typedef Foo Bar__Baz;
  CODE:
    RETVAL = THIS->add( other );
  OUTPUT: RETVAL

int
Bar::Baz::add_int( int other )
  PREINIT:
    typedef Foo Bar__Baz;
  CODE:
    RETVAL = THIS->add_int( other );
  OUTPUT: RETVAL
--- preamble
struct Foo {
    Foo(int v) : value(v) { }

    Foo *inc() { value++; return this; }
    int add(Foo *other) { return value + other->value; }
    int add_int(int other) { return value + other; }

    int value;
};
--- test_code
my $foo1 = Bar::Baz->new( 5 );
my $foo2 = $foo1->inc;
my $foo3 = Bar::Baz->new( 4 );

isa_ok( $foo1, 'Bar::Baz' );
isa_ok( $foo2, 'Bar::Baz' );
isa_ok( $foo3, 'Bar::Baz' );
is( $$foo1, $$foo2 );
isnt( $$foo1, $$foo3 );
is( $foo1->add($foo3 ), 10 );
