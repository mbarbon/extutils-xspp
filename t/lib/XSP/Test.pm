package t::lib::XSP::Test;

use strict;
use warnings;
use if -d 'blib' => 'blib';

use Test::Base -Base;
use Test::Differences;
use ExtUtils::XSpp::Typemap;
use File::Temp qw(tempdir);

{
    no warnings 'redefine';

    # Test::Base is way too clever
    *Test::Base::run_compare = sub { };
}

our @EXPORT = qw(run_diff);
my $COMPILE = $ENV{XSP_COMPILE} || -f '.gitignore';
my $OUTDIR = $COMPILE ? tempdir( CLEANUP => 1 ) : undef;

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
                    _munge_output( $b_expected ), "xsp output - $name" );

        if ( $COMPILE ) {
            my ( $preamble, $typemap, $test ) = ( $block->preamble // '', $block->typemap // '', $block->test_code // '' );

            if ( $preamble || $typemap ) {
                if ( compile_ok( $b_got, $preamble, $typemap, $name ) ) {
                    if ( $test ) {
                        test_ok( $test, $name );
                    } else {
                        Test::More::note( "no test code for - $name" );
                    }
                }
            } else {
                Test::More::note( "no preamble/typemap compilation test - $name" );
            }
        }
    };

    Test::More::done_testing();
}

sub compile_ok($$$$) {
    my ( $xs_code, $preamble_code, $typemap_code, $name ) = @_;

    require ExtUtils::ParseXS;
    require ExtUtils::CBuilder;
    require ExtUtils::CppGuess;

    my $guess = ExtUtils::CppGuess->new;
    my $pxs = ExtUtils::ParseXS->new;
    my %guessed = $guess->module_build_options;
    my $builder = ExtUtils::CBuilder->new( quiet => 1 );

    my $xs = $OUTDIR . '/XspTest.xs';
    my $typemap = $OUTDIR . '/typemap';
    my $cpp = $OUTDIR . '/XspTest.cpp';
    my $obj = $builder->object_file( $cpp );

    {
        open my $fh, '>', $xs or die "Unable to open '$xs': $!";
        print $fh <<'EOT';
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

EOT
        print $fh $preamble_code;
        print $fh $xs_code;
        close $fh;
    }
    {
        open my $fh, '>', $typemap or die "Unable to open '$typemap': $!";
        print $fh $typemap_code;
        close $fh;
    }

    $pxs->process_file(
        filename    => $xs,
        output      => $cpp,
        typemap     => $typemap,
        'C++'       => 1,
        prototypes  => 1,
    );
    if ($pxs->report_error_count()) {
        fail( "XS parsing failed - $name" );
        return;
    }
    $builder->compile(
        source                  => $cpp,
        object_file             => $obj,
        'C++'                   => 1,
        extra_compiler_flags    => $guessed{extra_compiler_flags},
    );
    $builder->link(
        objects             => [ $obj ],
        module_name         => 'XspTest',
        extra_linker_flags  => $guessed{extra_linker_flags},
    );

    ok( 1, "compilation - $name" );
}

sub test_ok($) {
    require TAP::Harness;

    my ($test_code, $name) = @_;

    my $module = $OUTDIR . '/XspTest.pm';
    my $test = $OUTDIR . '/xsp.t';

    {
        open my $fh, '>', $module or die "Unable to open '$module': $!";
        print $fh <<'EOT';
package XspTest;

use XSLoader;

XSLoader::load(__PACKAGE__);

1;
EOT
        close $fh;
    }
    {
        open my $fh, '>', $test or die "Unable to open '$test': $!";
        print $fh <<'EOT';
use strict;
use warnings;
use XspTest;
use Test::More;
use Test::Differences;
#line 1 "test code"
EOT
        print $fh $test_code;
        print $fh sprintf(<<'EOT', $test);
#line 6 "%s"
done_testing();
EOT
        close $fh;
    }

    my $output;
    open my $capture, '>', \$output;
    my $harness = TAP::Harness->new({
        lib         => [ $OUTDIR ],
        verbosity   => 1,
        stdout      => $capture,
        merge       => 1,
    });
    my $aggregator = $harness->runtests( $test );
    if ( $aggregator->all_passed ) {
        ok(1, "runtime check - $name");
    } else {
        fail("runtime check - $name");
        diag("\nsubtest output\n");
        diag( $output );
    }
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
