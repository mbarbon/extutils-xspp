#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 3;

use ExtUtils::XSpp;
use ExtUtils::XSpp::Typemap::simplexs;

is(ExtUtils::XSpp::Typemap::get_xs_typemap_code_for_all_typemaps(), '');
my $tm = ExtUtils::XSpp::Typemap::simplexs->new(
  type => ExtUtils::XSpp::Node::Type->new(
    base => 'foo',
    pointer => 1,
  ),
  xs_type => 'T_FOO',
);
ExtUtils::XSpp::Typemap::add_typemap_for_type(foo => $tm);

my $typemap_code = ExtUtils::XSpp::Typemap::get_xs_typemap_code_for_all_typemaps();
ok($typemap_code =~ /^TYPEMAP: <</);
ok($typemap_code =~ /^foo\s*\*\s*T_FOO\b/m);

