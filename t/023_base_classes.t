#!/usr/bin/perl -w

use t::lib::XSP::Test;

run_diff xsp_stdout => 'expected';

__DATA__

=== Classes with base classes
--- xsp_stdout
%module{XspTest};

class Foo : public Moo
{
    void foo();
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

void
Foo::foo()
  CODE:
    try {
      THIS->foo();
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }

BOOT:
    {
        AV* isa = get_av( "Foo::ISA", 1 );
        av_store( isa, 0, newSVpv( "Moo", 0 ) );
    } // blank line here is important

=== Classes with renamed base classes
--- xsp_stdout
%module{XspTest};

class Foo : public %name{PlMoo} Moo, public Boo
{
    void foo();
};
--- expected
# XSP preamble


MODULE=XspTest

MODULE=XspTest PACKAGE=Foo

void
Foo::foo()
  CODE:
    try {
      THIS->foo();
    }
    catch (std::exception& e) {
      croak("Caught C++ exception of type or derived from 'std::exception': %s", e.what());
    }
    catch (...) {
      croak("Caught C++ exception of unknown type");
    }

BOOT:
    {
        AV* isa = get_av( "Foo::ISA", 1 );
        av_store( isa, 0, newSVpv( "PlMoo", 0 ) );
        av_store( isa, 0, newSVpv( "Boo", 0 ) );
    } // blank line here is important
