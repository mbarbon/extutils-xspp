#!/usr/bin/perl -w

use lib 't/lib';
use XSP::Test;

# monkeypatch Enum/EnumValue just to test that they were parsed correctly
no warnings 'redefine';

sub ExtUtils::XSpp::Node::Enum::print {
    return join "\n", '// ' . ( $_[0]->name || '<anonymous>' ),
                      map $_->print, @{$_[0]->elements};
}

sub ExtUtils::XSpp::Node::EnumValue::print {
    return '//     ' . $_[0]->name;
}

run_diff xsp_stdout => 'expected';

__DATA__

=== Parse and ignore named enums
--- xsp_stdout
%module{XspTest};

enum Values
{
    ONE = 1,
    TWO,
    THREE,
};
--- expected
# XSP preamble


MODULE=XspTest
// Values
//     ONE
//     TWO
//     THREE

=== Parse and ignore anonymout enums
--- xsp_stdout
%module{XspTest};

enum
{
    ONE,
    TWO,
    THREE
};
--- expected
# XSP preamble


MODULE=XspTest
// <anonymous>
//     ONE
//     TWO
//     THREE

