#!/usr/bin/perl -w

use t::lib::XSP::Test;

run_diff xsp_stdout => 'expected';

__DATA__

=== Basic class
--- xsp_stdout
%module{XspTest};

class Foo
{
    int foo( int a, int b, int c );
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

int
Foo::foo( int a, int b, int c )
  CODE:
    RETVAL = THIS->foo( a, b, c );
  OUTPUT: RETVAL
--- typemap
Foo *   T_PTRREF
--- preamble
struct Foo {
    int foo( int a, int b, int c ) { return a + b + c; }
};
--- test_code
my $foo = \( my $bar = 1 );
bless $foo, 'Foo';
is( $foo->foo( 3, 4, 5 ), 12 );

=== Empty class
--- xsp_stdout
%module{XspTest};

class Foo
{
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

=== Basic function
--- xsp_stdout
%module{XspTest};
%package{Foo::Bar};

int foo( int a );
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo::Bar

int
foo( int a )
  CODE:
    RETVAL = foo( a );
  OUTPUT: RETVAL
--- preamble
int foo( int a ) { return a + 1; }
--- test_code
is( Foo::Bar::foo( 3 ), 4 );

=== Default arguments
--- xsp_stdout
%module{XspTest};

class Foo
{
    int foo( int a = 1, int b = 0x1, int c = 1|2 );
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

int
Foo::foo( int a = 1, int b = 0x1, int c = 1 | 2 )
  CODE:
    RETVAL = THIS->foo( a, b, c );
  OUTPUT: RETVAL
--- typemap
Foo *   T_PTRREF
--- preamble
struct Foo {
    int foo( int a, int b, int c ) { return a + b + c; }
};
--- test_code
my $foo = \( my $bar = 1 );
bless $foo, 'Foo';
is( $foo->foo, 5 );
is( $foo->foo( 7 ), 11 );
is( $foo->foo( 7, 8 ), 18 );
is( $foo->foo( 7, 8, 9 ), 24 );

=== Constructor
--- xsp_stdout
%module{XspTest};

class Foo
{
    Foo( int a = 1 );
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

#undef  xsp_constructor_class
#define xsp_constructor_class(c) (CLASS)

Foo*
Foo::new( int a = 1 )
  CODE:
    RETVAL = new Foo( a );
  OUTPUT: RETVAL

#undef  xsp_constructor_class
#define xsp_constructor_class(c) (c)
--- typemap
Foo *   T_PTRREF
--- preamble
struct Foo {
    Foo( int a ) { }
};

=== Destructor
--- xsp_stdout
%module{XspTest};

class Foo
{
    ~Foo();
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

void
Foo::DESTROY()
  CODE:
    delete THIS;
--- typemap
Foo *   T_PTRREF
--- preamble
struct Foo {
};

=== Void function
--- xsp_stdout
%module{XspTest};

class Foo
{
    void foo( int a );
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

void
Foo::foo( int a )
  CODE:
    THIS->foo( a );

=== No parameters
--- xsp_stdout
%module{XspTest};

class Foo
{
    void foo();
    void bar(void);
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

void
Foo::foo()
  CODE:
    THIS->foo();

void
Foo::bar()
  CODE:
    THIS->bar();

=== Comments and raw blocks
--- xsp_stdout
// comment before %module
## comment before %module

%module{XspTest};

## comment after %module
// comment after %module

{%
  Passed through verbatim
  as written in sources
%}

# simple typemaps
%typemap{int}{simple};

# before class
class Foo
{
    ## before method
    int foo( int a, int b, int c );
    # after method
};
/* long comment
 * right after
 * class
 */
--- expected
# XSP preamble



## comment before %module


MODULE=XspTest
## comment after %module




  Passed through verbatim
  as written in sources


# simple typemaps


# before class



MODULE=XspTest PACKAGE=Foo

## before method


int
Foo::foo( int a, int b, int c )
  CODE:
    RETVAL = THIS->foo( a, b, c );
  OUTPUT: RETVAL

# after method

=== %length and ANSI style
--- xsp_stdout
%module{XspTest};

%package{Bar};

unsigned int
bar( char* line, unsigned long %length{line} );
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Bar

unsigned int
bar( char* line, unsigned long length(line) )
  CODE:
    RETVAL = bar( line, XSauto_length_of_line );
  OUTPUT: RETVAL

=== %length and %code
--- xsp_stdout
%module{XspTest};

%package{Bar};

unsigned int
bar( char* line, unsigned long %length{line} )
  %code{%RETVAL = bar(length(line)*2);%};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Bar

unsigned int
bar( char* line, unsigned long length(line) )
  CODE:
    RETVAL = bar(XSauto_length_of_line*2);
  OUTPUT: RETVAL

=== %length and %postcall, %cleanup
--- xsp_stdout
%module{XspTest};

%package{Bar};

unsigned int
bar( char* line, unsigned long %length{line} )
  %postcall{% cout << length(line) << endl;%}
  %cleanup{% cout << 2*length(line) << endl;%};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Bar

unsigned int
bar( char* line, unsigned long length(line) )
  CODE:
    RETVAL = bar( line, XSauto_length_of_line );
  POSTCALL:
     cout << XSauto_length_of_line << endl;
  OUTPUT: RETVAL
  CLEANUP:
     cout << 2*XSauto_length_of_line << endl;

=== various integer types
--- xsp_stdout
%module{XspTest};

%package{Bar};

short int
bar( short a, unsigned short int b, unsigned c, unsigned int d, int e, unsigned short f, long int g, unsigned long int h );
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Bar

short
bar( short a, unsigned short b, unsigned int c, unsigned int d, int e, unsigned short f, long g, unsigned long h )
  CODE:
    RETVAL = bar( a, b, c, d, e, f, g, h );
  OUTPUT: RETVAL

=== verbatim code blocks for xsubs
--- xsp_stdout
%module{Wx};

%typemap{wxRichTextCtrl}{simple};
%name{Wx::RichTextCtrl} class wxRichTextCtrl
{
    %name{newDefault} wxRichTextCtrl()
        %code{% RETVAL = new wxRichTextCtrl();
                wxPli_create_evthandler( aTHX_ RETVAL, CLASS );
             %};
};
--- expected
# XSP preamble


MODULE=Wx

MODULE=Wx PACKAGE=Wx::RichTextCtrl

#undef  xsp_constructor_class
#define xsp_constructor_class(c) (CLASS)

static wxRichTextCtrl*
wxRichTextCtrl::newDefault()
  CODE:
     RETVAL = new wxRichTextCtrl();
                wxPli_create_evthandler( aTHX_ RETVAL, CLASS );
  OUTPUT: RETVAL

#undef  xsp_constructor_class
#define xsp_constructor_class(c) (c)
