package t::lib::XSP::Test;

use strict;
use warnings;
use if -d 'blib' => 'blib';

use Test::Base -Base;
use Test::Differences;
use ExtUtils::XSpp::Typemap;

{
    no warnings 'redefine';

    # Test::Base is way too clever
    *Test::Base::run_compare = sub { };
}

our @EXPORT = qw(run_diff);

# allows running tests both from t and from the top directory
use File::Spec;
BEGIN {
  if (-d 't') {
    unshift @INC, File::Spec->catdir(qw(t lib));
  }
  elsif (-d "lib") {
    unshift @INC, "lib";
  }
}

filters { xsp_stdout => 'xsp_stdout',
          xsp_file   => 'xsp_file',
          };

sub run_diff(@) {
    my( $got, $expected ) = @_;

    run {
        my $block = shift;
        my( $b_got, $b_expected, $name ) = ( $block->$got, $block->$expected, $block->name );

        eq_or_diff( _munge_output( $b_got ),
                    _munge_output( $b_expected ), $name );
    };

    Test::More::done_testing();
}

sub _munge_output($) {
    my $b_got = $_[0];

    # This removes the default typemap entry that is added for O_OBJECT
    # I admit that it doesn't make me feel all warm and fuzzy inside, but
    # the alternative of having even more code duplicated a lot of times in
    # all test files isn't any better.
    $b_got =~ s/^INPUT\s*\n.*^OUTPUT\s*\n.*^END\s*\n/END\n/sm;
    # remove some more repetitive preamble code
    $b_got =~ s|^#include <exception>\n.*?^#define xsp_constructor_class.*?\n|# XSP preamble\n|sm;
    # leading and trailing newlines
    $b_got =~ s/^\n+//s;
    $b_got =~ s/\n+$//s;

    return $b_got;
}

use ExtUtils::XSpp;

package t::lib::XSP::Test::Filter;

use Test::Base::Filter -base;

no warnings 'redefine';

# some fixed "random" values to simplify testing
my( @random_list, @random_digits ) =
    qw(017082 074990 737474 643532 738748 630394 284033);
sub ExtUtils::XSpp::Grammar::_random_digits {
    die "No more random values" unless @random_digits;
    return shift @random_digits;
}

sub xsp_stdout {
    ExtUtils::XSpp::Typemap::reset_typemaps();
    @random_digits = @random_list;
    my $d = ExtUtils::XSpp::Driver->new( string => shift, exceptions => 1 );
    my $out = $d->generate;
    ExtUtils::XSpp::Typemap::reset_typemaps();

    return $out->{'-'};
}

sub xsp_file {
    ExtUtils::XSpp::Typemap::reset_typemaps();
    @random_digits = @random_list;
    my $name = Test::Base::filter_arguments();
    my $d = ExtUtils::XSpp::Driver->new( string => shift, exceptions => 1 );
    my $out = $d->generate;
    ExtUtils::XSpp::Typemap::reset_typemaps();

    return $out->{$name};
}

1;
