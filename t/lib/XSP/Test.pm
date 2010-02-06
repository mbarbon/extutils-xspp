package t::lib::XSP::Test;

use strict;
use warnings;
use if -d 'blib' => 'blib';

use Test::Base -Base;
use Test::Differences;

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
        my( $b_got, $b_expected ) = map { s/^\n+//s; s/\n+$//s; $_ }
                                        $block->$got, $block->$expected;
        eq_or_diff( $b_got, $b_expected, $block->name);
    };
}

use ExtUtils::XSpp;

package t::lib::XSP::Test::Filter;

use Test::Base::Filter -base;

sub xsp_stdout {
    my $d = ExtUtils::XSpp::Driver->new( string => shift );
    my $out = $d->generate;

    return $out->{'-'};
}

sub xsp_file {
    my $name = Test::Base::filter_arguments();
    my $d = ExtUtils::XSpp::Driver->new( string => shift );
    my $out = $d->generate;

    return $out->{$name};
}

1;
