#!/usr/bin/perl -w

use lib 't/lib';
use XSP::Test;

use ExtUtils::XSpp;
use ExtUtils::XSpp::Typemap::simple;
use Test::Differences;

# First, add a manual typemap and see if that ends up in the generated
# typemap block.
is(ExtUtils::XSpp::Typemap::get_xs_typemap_code_for_all_typemaps(), undef);
my $type = ExtUtils::XSpp::Node::Type->new(
  base => 'bar',
  pointer => 1,
);
my $tm = ExtUtils::XSpp::Typemap::simple->new(
  type => $type,
  xs_type => 'T_BAR',
  xs_input_code => 'MY_IN($arg, $var, $type, $Package, $func_name, Bar)',
  xs_output_code => 'MY_OUT($arg, $var, Bar)',
);
ExtUtils::XSpp::Typemap::add_typemap_for_type($type => $tm);

# Check whether writing basic typemaps works.
my $typemap_code = ExtUtils::XSpp::Typemap::get_xs_typemap_code_for_all_typemaps();
eq_or_diff($typemap_code, <<'EXPECTED');
TYPEMAP: <<END
TYPEMAP
bar*	T_BAR

INPUT
T_BAR
	MY_IN($arg, $var, $type, $Package, $func_name, Bar)

OUTPUT
T_BAR
	MY_OUT($arg, $var, Bar)

END
EXPECTED

# Now check whether adding a class may overwrite existing typemaps.
# Process class of same name as manual typemap
my $d = ExtUtils::XSpp::Driver->new( string => <<'HERE', exceptions => 0 );
%module{Foo2};

class bar
{
    int foo2( int a, int b, int c );
};
HERE

eq_or_diff($d->generate->{'-'}, <<'HERE');
#undef  xsp_constructor_class
#define xsp_constructor_class(c) (c)


MODULE=Foo2
TYPEMAP: <<END
TYPEMAP
bar*	T_BAR

INPUT
T_BAR
	MY_IN($arg, $var, $type, $Package, $func_name, Bar)

OUTPUT
T_BAR
	MY_OUT($arg, $var, Bar)

END

MODULE=Foo2 PACKAGE=bar

int
bar::foo2( int a, int b, int c )
  CODE:
    RETVAL = THIS->foo2( a, b, c );
  OUTPUT: RETVAL

HERE

# Now parse a normal class, which will auto-add a typemap entry
run_diff xsp_stdout => 'expected';

__DATA__

=== Basic class
--- xsp_stdout
%module{Foo};

%loadplugin{feature::default_xs_typemap};

%typemap{bar *}{simple}{
    %xs_type{T_BAR};
};

class Foo
{
    int foo( int a, int b, int c );
};
--- expected
# XSP preamble


MODULE=Foo
TYPEMAP: <<END
TYPEMAP
const Foo*	O_OBJECT
Foo*	O_OBJECT
bar*	T_BAR

END
MODULE=Foo PACKAGE=Foo

int
Foo::foo( int a, int b, int c )
  CODE:
    RETVAL = THIS->foo( a, b, c );
  OUTPUT: RETVAL

=== Override default
--- xsp_stdout
%module{Foo};

%typemap{_}{simple}{
    %name{object};
    %xs_type{T_BAR};
    %xs_input_code{% MY_IN($arg, $var, $type, $Package, $func_name, Bar) %};
    %xs_output_code{% MY_OUT($arg, $var, Bar) %};
};

class Foo
{
    int foo( int a, int b, int c );
};
--- expected
# XSP preamble


MODULE=Foo
TYPEMAP: <<END
TYPEMAP
const Foo*	T_BAR
Foo*	T_BAR

END
MODULE=Foo PACKAGE=Foo

int
Foo::foo( int a, int b, int c )
  CODE:
    RETVAL = THIS->foo( a, b, c );
  OUTPUT: RETVAL
