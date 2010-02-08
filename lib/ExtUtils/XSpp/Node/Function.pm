package ExtUtils::XSpp::Node::Function;
use strict;
use warnings;
use Carp ();
use base 'ExtUtils::XSpp::Node';

=head1 NAME

ExtUtils::XSpp::Node::Function - Node representing a function

=head1 DESCRIPTION

An L<ExtUtils::XSpp::Node> subclass representing a single function declaration
such as

  int foo();

More importantly, L<ExtUtils::XSpp::Node::Method> inherits from this class,
so all in here equally applies to method nodes.

=head1 METHODS

=head2 new

Creates a new C<ExtUtils::XSpp::Node::Function>.

Named parameters: C<cpp_name> indicating the C++ name of the function,
C<perl_name> indicating the Perl name of the function (defaults to the
same as C<cpp_name>), C<arguments> can be a reference to an
array of C<ExtUtils::XSpp::Node::Argument> objects,
C<ret_type> indicates the (C++) return type of the function,
and finally, C<class>, which can be an L<ExtUtils::XSpp::Node::Class>
object (FIXME: Should this be part of ::Function, not ::Method?)

Additionally, there are several optional decorators for a function
declaration (see L<ExtUtils::XSpp> for a list). These can be
passed to the constructor as C<code>, C<cleanup>, C<postcall>,
and C<catch>. C<catch> is special in that it must be a reference
to an array of class names.

=cut

sub init {
  my $this = shift;
  my %args = @_;

  $this->{CPP_NAME}  = $args{cpp_name};
  $this->{PERL_NAME} = $args{perl_name} || $args{cpp_name};
  $this->{ARGUMENTS} = $args{arguments} || [];
  $this->{RET_TYPE}  = $args{ret_type};
  $this->{CODE}      = $args{code};
  $this->{CLEANUP}   = $args{cleanup};
  $this->{POSTCALL}  = $args{postcall};
  $this->{CLASS}     = $args{class};
  $this->{CATCH}     = $args{catch};

  if (ref($this->{CATCH})
      and @{$this->{CATCH}} > 1
      and grep {$_ eq 'nothing'} @{$this->{CATCH}})
  {
    Carp::croak( ref($this) . " '" . $this->{CPP_NAME}
                 . "' is supposed to catch no exceptions, yet"
                 . " there are exception handlers ("
                 . join(", ", @{$this->{CATCH}}) . ")" );
  }
  return $this;
}

=head2 resolve_typemaps

Fetches the L<ExtUtils::XSpp::Typemap> object for
the return type and the arguments from the typemap registry
and stores a reference to those objects.

=cut

sub resolve_typemaps {
  my $this = shift;

  if( $this->ret_type ) {
    $this->{TYPEMAPS}{RET_TYPE} =
      ExtUtils::XSpp::Typemap::get_typemap_for_type( $this->ret_type );
  }
  foreach my $a ( @{$this->arguments} ) {
    my $t = ExtUtils::XSpp::Typemap::get_typemap_for_type( $a->type );
    push @{$this->{TYPEMAPS}{ARGUMENTS}}, $t;
  }
}


=head2 resolve_exceptions

Fetches the L<ExtUtils::XSpp::Exception> object for
the C<%catch> directives associated with this function.

=cut

sub resolve_exceptions {
  my $this = shift;

  my @catch = @{$this->{CATCH} || []};

  my @exceptions;

  # If this method is not hard-wired to catch nothing...
  if (not grep {$_ eq 'nothing'} @catch) {
    my %seen;
    foreach my $catch (@catch) {
      next if $seen{$catch}++;
      push @exceptions,
        ExtUtils::XSpp::Exception->get_exception_for_name($catch);
    }

    # If nothing else, catch std::exceptions nicely
    if (not @exceptions) {
      my $typenode = ExtUtils::XSpp::Node::Type->new(base => 'std::exception');
      push @exceptions,
        ExtUtils::XSpp::Exception::stdmessage->new( name => 'default',
                                                    type => $typenode );
    }
  }

  # Always catch the rest with an unspecific error message.
  # If the method is hard-wired to catch nothing, we lie to the user
  # for his own safety! (FIXME: debate this)
  push @exceptions,
    ExtUtils::XSpp::Exception::unknown->new( name => '', type => '' );

  $this->{EXCEPTIONS} = \@exceptions;
}

=head2 add_exception_handlers

Adds a list of exception names to the list of exception handlers.
This is mainly called by a class' C<add_methods> method.
If the function is hard-wired to have no exception handlers,
any extra handlers from the class are ignored.

=cut


sub add_exception_handlers {
  my $this = shift;

  # ignore class %catch'es if overridden with "nothing" in the method
  if ($this->{CATCH} and @{$this->{CATCH}} == 1
      and $this->{CATCH} eq 'nothing') {
    return();
  }

  # ignore class %catch{nothing} if overridden in the method
  if (@_ == 1 and $_[0] eq 'nothing' and @{$this->{CATCH}}) {
    return();
  }

  $this->{CATCH} ||= [];
  push @{$this->{CATCH}}, @_;

  return();
}


=head2 argument_style

Returns either C<ansi> or C<kr>. C<kr> is the default.
C<ansi> is returned if any one of the arguments uses the XS
C<length> feature.

=cut

sub argument_style {
  my $this = shift;
  foreach my $arg (@{$this->{ARGUMENTS}}) {
    return 'ansi' if $arg->name =~ /length.*\(/;
  }
  return 'kr';
}

# Depending on argument style, this produces either: (style=kr)
#
# return_type
# class_name::function_name( args = def, ... )
#     type arg
#     type arg
#   PREINIT:
#     aux vars
#   [PP]CODE:
#     RETVAL = new Foo( THIS->method( arg1, *arg2 ) );
#   POSTCALL:
#     /* anything */
#   OUTPUT:
#     RETVAL
#   CLEANUP:
#     /* anything */
#
# Or: (style=ansi)
#
# return_type
# class_name::function_name( type arg1 = def, type arg2 = def, ... )
#   PREINIT:
# (rest as above)

sub print {
  my $this               = shift;
  my $state              = shift;

  my $out                = '';
  my $fname              = $this->perl_function_name;
  my $args               = $this->arguments;
  my $ret_type           = $this->ret_type;
  my $ret_typemap        = $this->{TYPEMAPS}{RET_TYPE};
  my $need_call_function = 0;

  my( $init, $arg_list, $call_arg_list, $code, $output, $cleanup,
      $postcall, $precall ) =
    ( '', '', '', '', '', '', '', '' );

  my $use_ansi_style = $this->argument_style() eq 'ansi';

  if( $args && @$args ) {
    my $has_self = $this->is_method ? 1 : 0;
    my( @arg_list, @call_arg_list );
    foreach my $i ( 0 .. $#$args ) {
      my $arg = ${$args}[$i];
      my $t   = $this->{TYPEMAPS}{ARGUMENTS}[$i];
      my $pc  = $t->precall_code( sprintf( 'ST(%d)', $i + $has_self ),
                                  $arg->name );

      $need_call_function ||=    defined $t->call_parameter_code( '' )
                              || defined $pc;
      my $type = $use_ansi_style ? $t->cpp_type . ' ' : '';
      push @arg_list, $type . $arg->name .
                      ( $arg->has_default ? ' = ' . $arg->default : '' );
      if (!$use_ansi_style) {
        $init .= '    ' . $t->cpp_type . ' ' . $arg->name . "\n";
      }

      my $call_code = $t->call_parameter_code( $arg->name );
      push @call_arg_list, defined( $call_code ) ? $call_code : $arg->name;
      $precall .= $pc . ";\n" if $pc
    }

    $arg_list = ' ' . join( ', ', @arg_list ) . ' ';
    $call_arg_list = ' ' . join( ', ', @call_arg_list ) . ' ';
  }

  # same for return value
  $need_call_function ||= $ret_typemap &&
    ( defined $ret_typemap->call_function_code( '', '' ) ||
      defined $ret_typemap->output_code ||
      defined $ret_typemap->cleanup_code );
  # is C++ name != Perl name?
  $need_call_function ||= $this->cpp_name ne $this->perl_name;
  # package-static function
  $need_call_function ||= $this->package_static;

  my $retstr = $ret_typemap ? $ret_typemap->cpp_type : 'void';

  # special case: constructors with name different from 'new'
  # need to be declared 'static' in XS
  if( $this->isa( 'ExtUtils::XSpp::Node::Constructor' ) &&
      $this->perl_name ne $this->cpp_name ) {
    $retstr = "static $retstr";
  }

  my $has_ret = $ret_typemap && !$ret_typemap->type->is_void;

  # Hardcoded to one because we force the exception handling for now
  # All the hard work above about determining whether $need_call_function
  # needs to be enabled is left in as exception handling may be subject
  # to configuration later. --Steffen
  $need_call_function = 1;

  if( $need_call_function ) {
    my $ccode = $this->_call_code( $call_arg_list );
    if ($this->isa('ExtUtils::XSpp::Node::Destructor')) {
      $ccode = 'delete THIS';
      $has_ret = 0;
    } elsif( $has_ret && defined $ret_typemap->call_function_code( '', '' ) ) {
      $ccode = $ret_typemap->call_function_code( $ccode, 'RETVAL' );
    } elsif( $has_ret ) {
      $ccode = "RETVAL = $ccode";
    }

    $code .= "  CODE:\n";
    $code .= "    try {\n";
    $code .= '      ' . $precall if $precall;
    $code .= '      ' . $ccode . ";\n";
    if( $has_ret && defined $ret_typemap->output_code ) {
      $code .= '      ' . $ret_typemap->output_code . ";\n";
    }
    $code .= "    }\n";
    my @catchers = @{$this->{EXCEPTIONS}};
    foreach my $exception_handler (@catchers) {
      $code .= $exception_handler->handler_code;
    }

    $output = "  OUTPUT: RETVAL\n" if $has_ret;

    if( $has_ret && defined $ret_typemap->cleanup_code ) {
      $cleanup .= "  CLEANUP:\n";
      $cleanup .= '    ' . $ret_typemap->cleanup_code . ";\n";
    }
  }

  if( $this->code ) {
    $code = "  CODE:\n    " . join( "\n", @{$this->code} ) . "\n";
    # cleanup potential multiple newlines because they break XSUBs
    $code =~ s/^\s*\z//m;
    $output = "  OUTPUT: RETVAL\n" if $code =~ m/\bRETVAL\b/;
  }
  if( $this->postcall ) {
    $postcall = "  POSTCALL:\n    " . join( "\n", @{$this->postcall} ) . "\n";
    $output ||= "  OUTPUT: RETVAL\n" if $has_ret;
  }
  if( $this->cleanup ) {
    $cleanup ||= "  CLEANUP:\n";
    my $clcode = join( "\n", @{$this->cleanup} );
    $cleanup .= "    $clcode\n";
  }

  if( !$this->is_method && $fname =~ /^(.*)::(\w+)$/ ) {
    my $pcname = $1;
    $fname = $2;
    my $cur_module = $state->{current_module}->to_string;
    $out .= <<EOT;
$cur_module PACKAGE=$pcname

EOT
  }

  $out .= "$retstr\n";
  $out .= "$fname($arg_list)\n";
  $out .= $init;
  $out .= $code;
  $out .= $postcall;
  $out .= $output;
  $out .= $cleanup;
  $out .= "\n";
}

=head2 perl_function_name

Returns the name of the Perl function to generate.

=cut

sub perl_function_name { $_[0]->perl_name }

=head2 is_method

Returns whether the object at hand is a method. Hard-wired
to be false for C<ExtUtils::XSpp::Node::Function> object,
but overridden in the L<ExtUtils::XSpp::Node::Method> sub-class.

=cut

sub is_method { 0 }

=begin documentation

ExtUtils::XSpp::Node::_call_code( argument_string )

Return something like "foo( $argument_string )".

=end documentation

=cut

sub _call_code { return $_[0]->cpp_name . '(' . $_[1] . ')'; }


=head1 ACCESSORS

=head2 cpp_name

Returns the C++ name of the function.

=head2 perl_name

Returns the Perl name of the function (defaults to same as C++).

=head2 set_perl_name

Sets the Perl name of the function.

=head2 arguments

Returns the internal array reference of L<ExtUtils::XSpp::Node::Argument>
objects that represent the function arguments.

=head2 ret_type

Returns the C++ return type.

=head2 code

Returns the C<%code> decorator if any.

=head2 cleanup

Returns the C<%cleanup> decorator if any.

=head2 postcall

Returns the C<%postcall> decorator if any.

=head2 virtual

Returns whether the method was declared virtual.

=head2 set_virtual

Set whether the method is to be considered virtual.

=head2 catch

Returns the set of exception types that were associated
with the function via C<%catch>. (array reference)

=cut

sub cpp_name { $_[0]->{CPP_NAME} }
sub perl_name { $_[0]->{PERL_NAME} }
sub set_perl_name { $_[0]->{PERL_NAME} = $_[1] }
sub arguments { $_[0]->{ARGUMENTS} }
sub ret_type { $_[0]->{RET_TYPE} }
sub code { $_[0]->{CODE} }
sub cleanup { $_[0]->{CLEANUP} }
sub postcall { $_[0]->{POSTCALL} }
sub virtual { $_[0]->{VIRTUAL} }
sub set_virtual { $_[0]->{VIRTUAL} = $_[1] }
sub catch { $_[0]->{CATCH} ? $_[0]->{CATCH} : [] }

=head2 set_static

Sets the C<static>-ness attribute of the function.
Can be either undef (i.e. not static), C<package_static>,
or C<class_static>.

=head2 package_static

Returns whether the function is package static.

=head2 class_static

Returns whether the function is class static.

=cut

sub set_static { $_[0]->{STATIC} = $_[1] }
sub package_static { ( $_[0]->{STATIC} || '' ) eq 'package_static' }
sub class_static { ( $_[0]->{STATIC} || '' ) eq 'class_static' }


1;
