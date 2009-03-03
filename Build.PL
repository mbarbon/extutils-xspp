#!/usr/bin/perl -w

use strict;
use warnings;
use lib 'inc';

use My::Build;

my $build = My::Build->new
  ( module_name => 'ExtUtils::XSpp',
    license     => 'perl',
    requires    => { 'perl'          => '5.6.1',
                     },
    add_to_cleanup => [ qw(t/files/foo.h) ],
    );
$build->create_build_script;
