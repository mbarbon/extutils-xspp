#!/usr/bin/perl -w

use strict;
use warnings;
use t::lib::XSP::Test tests => 3;

run_diff process => 'expected';

__DATA__

=== if, else, endif
--- process xsp_stdout
#include "foo.h"

#if SIZEOF_INT > 4
#error 1
#else
#error 2
#endif
--- expected
#include <exception>


#include "foo.h"


#if SIZEOF_INT > 4
#define XSpp_zzzzzzzz_017082

#error 1


#else
#define XSpp_zzzzzzzz_074990

#error 2


#endif

=== if, elif, endif
--- process xsp_stdout
#include "foo.h"

#if SIZEOF_INT > 4
#error 1
#elif SIZEOF_INT > 2
#error 2
#endif
--- expected
#include <exception>


#include "foo.h"


#if SIZEOF_INT > 4
#define XSpp_zzzzzzzz_017082

#error 1


#elif SIZEOF_INT > 2
#define XSpp_zzzzzzzz_074990

#error 2


#endif

=== ifdef, ifndef
--- process xsp_stdout
#include "foo.h"

#ifdef SIZEOF_INT
#error 1
#endif

#ifndef SIZEOF_INT
#error 2
#endif
--- expected
#include <exception>


#include "foo.h"


#ifdef SIZEOF_INT
#define XSpp_zzzzzzzz_017082

#error 1


#endif

#ifndef SIZEOF_INT
#define XSpp_zzzzzzzz_074990

#error 2


#endif
