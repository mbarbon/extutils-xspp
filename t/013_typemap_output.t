#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 4;

use ExtUtils::XSpp;
use ExtUtils::XSpp::Typemap::simple;
use Test::Differences;

# First, add a manual typemap and see if that ends up in the generated
# typemap block.
is(ExtUtils::XSpp::Typemap::get_xs_typemap_code_for_all_typemaps(), '');
my $type = ExtUtils::XSpp::Node::Type->new(
  base => 'bar',
  pointer => 1,
);
my $tm = ExtUtils::XSpp::Typemap::simple->new(
  type => $type,
  xs_type => 'T_BAR',
);
ExtUtils::XSpp::Typemap::add_typemap_for_type($type => $tm);

# Check whether writing basic typemaps works.
my $typemap_code = ExtUtils::XSpp::Typemap::get_xs_typemap_code_for_all_typemaps();
eq_or_diff($typemap_code, <<'EXPECTED');
TYPEMAP: <<END
TYPEMAP
bar*	T_BAR

END
EXPECTED

# Now parse a normal class, which will auto-add a typemap entry
run_diff xsp_stdout => 'expected';

# re-add typemap since the test code clears them
ExtUtils::XSpp::Typemap::add_typemap_for_type($type => $tm);

# Now check whether adding a class may overwrite existing typemaps.
# Process class of same name as manual typemap
my $d = ExtUtils::XSpp::Driver->new( string => <<'HERE' );
%module{Foo2};

class bar
{
    int foo2( int a, int b, int c );
};
HERE

eq_or_diff($d->generate->{'-'}, <<'HERE');
TYPEMAP: <<END
TYPEMAP
bar*	T_BAR

END
# XSP preamble
#include <exception>
#undef  xsp_constructor_class
#define xsp_constructor_class(c) (c)
# XSP preamble


MODULE=Foo2

MODULE=Foo2 PACKAGE=bar

int
bar::foo2( int a, int b, int c )
  CODE:
    try {
      RETVAL = THIS->foo2( a, b, c );
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL

HERE

__DATA__

=== Basic class
--- xsp_stdout
%module{Foo};

class Foo
{
    int foo( int a, int b, int c );
};
--- expected
TYPEMAP: <<END
TYPEMAP
Foo*	O_OBJECT
bar*	T_BAR

END
# XSP preamble


MODULE=Foo

MODULE=Foo PACKAGE=Foo

int
Foo::foo( int a, int b, int c )
  CODE:
    try {
      RETVAL = THIS->foo( a, b, c );
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }
  OUTPUT: RETVAL


