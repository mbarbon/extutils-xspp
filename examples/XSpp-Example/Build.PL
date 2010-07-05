#!/usr/bin/perl -w
use strict;
use Module::Build::WithXSpp;

my $build = Module::Build::WithXSpp->new(
  module_name     => 'XSpp::Example',
  license         => 'perl',
  requires        => {},
  configure_requires => {
    'Module::Build::WithXSpp' => '0.01',
  },
);

$build->create_build_script;
