#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 2;
use File::Spec;
BEGIN {
  if (-d 't') {
    unshift @INC, File::Spec->catdir(qw(t lib));
  }
  elsif (-d "lib") {
    unshift @INC, "lib";
  }
}

run_diff xsp_stdout => 'expected';

__DATA__

=== Basic plugin functionality
--- xsp_stdout
%module{Foo};
%package{Foo};
%loadplugin{t::lib::XSP::Plugin};

%typemap{int}{simple};
%typemap{void}{simple};

int foo(int y);

class Y
{
    void bar();
};
--- expected
MODULE=Foo PACKAGE=Foo

int
foo_perl( y )
    int y
  CODE:
    RETVAL = foo( y );
  OUTPUT: RETVAL


MODULE=Foo PACKAGE=Y

void
Y::bar()
=== Plugin loading from the plugin namespace
--- xsp_stdout
%module{Foo};
%package{Foo};
%loadplugin{TestPlugin};

%typemap{int}{simple};
%typemap{void}{simple};

int foo(int y);

class Y
{
    void bar();
};
--- expected
MODULE=Foo PACKAGE=Foo

int
foo_perl2( y )
    int y
  CODE:
    RETVAL = foo( y );
  OUTPUT: RETVAL


MODULE=Foo PACKAGE=Y

void
Y::bar()
