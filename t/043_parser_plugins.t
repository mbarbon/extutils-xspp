#!/usr/bin/perl -w

use lib 't/lib';
use XSP::Test;

run_diff xsp_stdout => 'expected';

__DATA__

=== Handle class/method/function annotations
--- xsp_stdout
%module{XspTest};
%package{Foo};
%loadplugin{TestParserPlugin};
%loadplugin{TestNewNodesPlugin};

int foo(int y) %MyFuncRename{Foo} %MyComment;

class klass
{
    %MyClassRename{Klass};
    %MyComment;

    klass() %MyMethodRename{newKlass} %MyComment;

    void bar() %MyMethodRename{Bar} %MyComment;
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

int
Foo( int y )
  CODE:
    RETVAL = foo( y );
  OUTPUT: RETVAL

// function foo



MODULE=XspTest PACKAGE=Klass

#undef  xsp_constructor_class
#define xsp_constructor_class(c) (CLASS)

static klass*
klass::newKlass()
  CODE:
    RETVAL = new klass();
  OUTPUT: RETVAL

#undef  xsp_constructor_class
#define xsp_constructor_class(c) (c)

void
klass::Bar()
  CODE:
    THIS->bar();

// method klass::klass


// method klass::bar


// class klass

=== Handle top level directives
--- xsp_stdout
%module{XspTest};
%package{Foo};
%loadplugin{TestParserPlugin};
%loadplugin{TestNewNodesPlugin};

%MyDirective{Foo};
%MyComment;

--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

// directive MyComment


// Foo

=== Handle argument annotations
--- xsp_stdout
%module{XspTest};

%loadplugin{TestArgumentPlugin};

class klass
{
    int bar(int bar, int foo %MyWrap) %MyWrap;
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=klass

int
klass::bar( int bar, int foo )
  CODE:
      // wrapped typemap 1;
    RETVAL = THIS->bar( bar, foo );
  OUTPUT: RETVAL
  CLEANUP:
    // wrapped typemap ret;

=== Handle member annotations
--- xsp_stdout
%module{XspTest};

class klass
{
    int foo;
    %name{baz} int bar;
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=klass
