#!/usr/bin/perl -w
use strict;
use Module::Build::WithXSpp;

my $build = Module::Build::WithXSpp->new(
  module_name     => 'XSpp::Example',
  license         => 'perl',
  requires        => {},
);

$build->create_build_script;
