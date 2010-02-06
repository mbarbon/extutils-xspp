#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 1;

run_diff xsp_stdout => 'expected';

__DATA__

=== Basic exception declaration
--- xsp_stdout
%exception{myException}{std::exception}{stdmessage};

--- expected

