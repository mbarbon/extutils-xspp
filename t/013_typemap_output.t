#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 4;

use ExtUtils::XSpp;
use ExtUtils::XSpp::Typemap::simplexs;

is(ExtUtils::XSpp::Typemap::get_xs_typemap_code_for_all_typemaps(), '');
my $type = ExtUtils::XSpp::Node::Type->new(
  base => 'bar',
  pointer => 1,
);
my $tm = ExtUtils::XSpp::Typemap::simplexs->new(
  type => $type,
  xs_type => 'T_BAR',
);
ExtUtils::XSpp::Typemap::add_typemap_for_type($type => $tm);

my $typemap_code = ExtUtils::XSpp::Typemap::get_xs_typemap_code_for_all_typemaps();
ok($typemap_code =~ /^TYPEMAP: <</);
ok($typemap_code =~ /^bar\s*\*\s*T_BAR\b/m);

run_diff xsp_stdout => 'expected';

$typemap_code = ExtUtils::XSpp::Typemap::get_xs_typemap_code_for_all_typemaps();
warn $typemap_code; # FIXME finish implementing test

__DATA__

=== Basic class
--- xsp_stdout
%module{Foo};

class Foo
{
    int foo( int a, int b, int c );
};
--- expected
#include <exception>


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


