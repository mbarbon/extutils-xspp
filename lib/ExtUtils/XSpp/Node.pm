package ExtUtils::XSpp::Node;

=head1 NAME

ExtUtils::XSpp::Node - Base class for the parser output.

=cut

use strict;
use warnings;

sub new {
  my $class = shift;
  my $this = bless {}, $class;

  $this->init( @_ );

  return $this;
}

=head2 ExtUtils::XSpp::Node::print

Return a string to be output in the final XS file.
Every class must override this method.

=cut

package ExtUtils::XSpp::Node::Raw;

=head1 ExtUtils::XSpp::Node::Raw

Contains data that should be output "as is" in the destination file.

=cut

use strict;
use base 'ExtUtils::XSpp::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{ROWS} = $args{rows};
  push @{$this->{ROWS}}, "\n";
}

=head2 ExtUtils::XSpp::Node::Raw::rows

Returns an array reference holding the rows to be output in the final file.

=cut

sub rows { $_[0]->{ROWS} }
sub print { join( "\n", @{$_[0]->rows} ) . "\n" }

package ExtUtils::XSpp::Node::Comment;

=head1 ExtUtils::XSpp::Node::Comment

Contains data that should be output prefixed with a comment marker

=cut

use strict;
use base 'ExtUtils::XSpp::Node::Raw';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{ROWS} = $args{rows};
}

sub print {
  my $this = shift;
  my $state = shift;

  return "\n";
}

package ExtUtils::XSpp::Node::Package;

=head1 ExtUtils::XSpp::Node::Package

Used to put global functions inside a Perl package.

=cut

use strict;
use base 'ExtUtils::XSpp::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{CPP_NAME} = $args{cpp_name};
  $this->{PERL_NAME} = $args{perl_name} || $args{cpp_name};
}

=head2 ExtUtils::XSpp::Node::Package::cpp_name

Returns the C++ name for the package (will be used for namespaces).

=head2 ExtUtils::XSpp::Node::Package::perl_name

Returns the Perl name for the package.

=cut

sub cpp_name { $_[0]->{CPP_NAME} }
sub perl_name { $_[0]->{PERL_NAME} }
sub set_perl_name { $_[0]->{PERL_NAME} = $_[1] }

sub print {
  my $this = shift;
  my $state = shift;
  my $out = '';
  my $pcname = $this->perl_name;

  if( !defined $state->{current_module} ) {
    die "No current module: remember to add a %module{} directive";
  }
  my $cur_module = $state->{current_module}->to_string;

  $out .= <<EOT;

$cur_module PACKAGE=$pcname

EOT

  return $out;
}

package ExtUtils::XSpp::Node::Class;

=head1 ExtUtils::XSpp::Node::Class

A class (inherits from Package).

=cut

use strict;
use base 'ExtUtils::XSpp::Node::Package';

sub init {
  my $this = shift;
  my %args = @_;

  $this->SUPER::init( @_ );
  $this->{METHODS} = $args{methods} || [];
  $this->{BASE_CLASSES} = $args{base_classes} || [];
}

=head2 ExtUtils::XSpp::Node::Class::methods

=cut

sub methods { $_[0]->{METHODS} }
sub base_classes { $_[0]->{BASE_CLASSES} }

sub add_methods {
  my $this = shift;
  my $access = 'public'; # good enough for now
  foreach my $meth ( @_ ) {
      if( $meth->isa( 'ExtUtils::XSpp::Node::Method' ) ) {
          $meth->{CLASS} = $this;
          $meth->{ACCESS} = $access;
          $meth->resolve_typemaps;
      } elsif( $meth->isa( 'ExtUtils::XSpp::Node::Access' ) ) {
          $access = $meth->access;
          next;
      }
      push @{$this->{METHODS}}, $meth;
  }
}

sub print {
  my $this = shift;
  my $state = shift;
  my $out = $this->SUPER::print( $state );

  foreach my $m ( @{$this->methods} ) {
    $out .= $m->print( $state );
  }

  # add a BOOT block for base classes
  if( @{$this->base_classes} ) {
      my $class = $this->perl_name;

      $out .= <<EOT;
BOOT:
    {
        AV* isa = get_av( "${class}::ISA", 1 );
EOT

    foreach my $b ( @{$this->base_classes} ) {
      my $base = $b->perl_name;

      $out .= <<EOT;
        av_store( isa, 0, newSVpv( "$base", 0 ) );
EOT
    }

      # close block in BOOT
      $out .= <<EOT;
    } // blank line here is important

EOT
  }

  return $out;
}

package ExtUtils::XSpp::Node::Access;

=head1 ExtUtils::XSpp::Node::Access

Access specifier.

=cut

use strict;
use base 'ExtUtils::XSpp::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{ACCESS} = $args{access};
}

sub access { $_[0]->{ACCESS} }

package ExtUtils::XSpp::Node::Function;

use strict;
use base 'ExtUtils::XSpp::Node';

=head1 ExtUtils::XSpp::Node::Function

A function; this is also a base class for C<Method>.

=cut

sub init {
  my $this = shift;
  my %args = @_;

  $this->{CPP_NAME} = $args{cpp_name};
  $this->{PERL_NAME} = $args{perl_name} || $args{cpp_name};
  $this->{ARGUMENTS} = $args{arguments} || [];
  $this->{RET_TYPE} = $args{ret_type};
  $this->{CODE} = $args{code};
  $this->{CLEANUP} = $args{cleanup};
  $this->{POSTCALL} = $args{postcall};
  $this->{CLASS} = $args{class};
}

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

=head2 ExtUtils::XSpp::Node::Function::cpp_name

=head2 ExtUtils::XSpp::Node::Function::perl_name

=head2 ExtUtils::XSpp::Node::Function::arguments

=head2 ExtUtils::XSpp::Node::Function::ret_type

=head2 ExtUtils::XSpp::Node::Function::code

=head2 ExtUtils::XSpp::Node::Function::cleanup

=head2 ExtUtils::XSpp::Node::Function::postcall

=head2 ExtUtils::XSpp::Node::Function::argument_style

Returns either C<ansi> or C<kr>. C<kr> is the default.
C<ansi> is returned if any one of the arguments uses the XS
C<length> feature.

=cut

sub cpp_name { $_[0]->{CPP_NAME} }
sub perl_name { $_[0]->{PERL_NAME} }
sub arguments { $_[0]->{ARGUMENTS} }
sub ret_type { $_[0]->{RET_TYPE} }
sub code { $_[0]->{CODE} }
sub cleanup { $_[0]->{CLEANUP} }
sub postcall { $_[0]->{POSTCALL} }
sub package_static { ( $_[0]->{STATIC} || '' ) eq 'package_static' }
sub class_static { ( $_[0]->{STATIC} || '' ) eq 'class_static' }
sub virtual { $_[0]->{VIRTUAL} }

sub set_perl_name { $_[0]->{PERL_NAME} = $_[1] }
sub set_static { $_[0]->{STATIC} = $_[1] }
sub set_virtual { $_[0]->{VIRTUAL} = $_[1] }

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
  my $this = shift;
  my $state = shift;
  my $out = '';
  my $fname = $this->perl_function_name;
  my $args = $this->arguments;
  my $ret_type = $this->ret_type;
  my $ret_typemap = $this->{TYPEMAPS}{RET_TYPE};
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
      my $t = $this->{TYPEMAPS}{ARGUMENTS}[$i];
      my $pc = $t->precall_code( sprintf( 'ST(%d)', $i + $has_self ),
                                 $arg->name );

      $need_call_function ||=    defined $t->call_parameter_code( '' )
                              || defined $pc;
      my $type = $use_ansi_style ? $t->cpp_type . ' ' : '';
      push @arg_list, $type . $arg->name . ( $arg->has_default ? ' = ' . $arg->default : '' );
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
    $code .= "    } catch (std::exception& e) {\n";
    $code .= '      croak("Caught unhandled C++ exception: %s", e.what());' . "\n";
    $code .= "    } catch (...) {\n";
    $code .= '      croak("Caught unhandled C++ exception of unknown type");' . "\n";
    $code .= "    }\n";

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

sub perl_function_name { $_[0]->perl_name }
sub is_method { 0 }

=begin documentation

ExtUtils::XSpp::Node::_call_code( argument_string )

Return something like "foo( $argument_string )".

=end documentation

=cut

sub _call_code { return $_[0]->cpp_name . '(' . $_[1] . ')'; }

package ExtUtils::XSpp::Node::Method;

use strict;
use base 'ExtUtils::XSpp::Node::Function';

sub class { $_[0]->{CLASS} }
sub perl_function_name { $_[0]->class->cpp_name . '::' .
                         $_[0]->perl_name }
sub _call_code {
    my( $self ) = @_;

    if( $self->package_static ) {
        return $_[0]->class->cpp_name . '::' .
               $_[0]->cpp_name . '(' . $_[1] . ')';
    } else {
        return "THIS->" .
               $_[0]->cpp_name . '(' . $_[1] . ')';
    }
}

sub is_method { 1 }

package ExtUtils::XSpp::Node::Constructor;

use strict;
use base 'ExtUtils::XSpp::Node::Method';

sub init {
  my $this = shift;
  $this->SUPER::init( @_ );

  die "Can't specify return value in constructor" if $this->{RET_TYPE};
}

sub ret_type {
  my $this = shift;

  ExtUtils::XSpp::Node::Type->new( base      => $this->class->cpp_name,
                            pointer   => 1 );
}

sub perl_function_name {
  my $this = shift;
  my( $pname, $cname, $pclass, $cclass ) = ( $this->perl_name,
                                             $this->cpp_name,
                                             $this->class->perl_name,
                                             $this->class->cpp_name );

  if( $pname ne $cname ) {
    return $cclass . '::' . $pname;
  } else {
    return $cclass . '::' . 'new';
  }
}

sub _call_code { return "new " . $_[0]->class->cpp_name .
                   '(' . $_[1] . ')'; }

package ExtUtils::XSpp::Node::Destructor;

use strict;
use base 'ExtUtils::XSpp::Node::Method';

sub init {
  my $this = shift;
  $this->SUPER::init( @_ );

  die "Can't specify return value in destructor" if $this->{RET_TYPE};
}

sub perl_function_name { $_[0]->class->cpp_name . '::' . 'DESTROY' }
sub ret_type { undef }

package ExtUtils::XSpp::Node::Argument;

use strict;
use base 'ExtUtils::XSpp::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{TYPE} = $args{type};
  $this->{NAME} = $args{name};
  $this->{DEFAULT} = $args{default};
}

sub print {
  my $this = shift;
  my $state = shift;

  return join( ' ',
               $this->type->print( $state ),
               $this->name,
               ( $this->default ?
                 ( '=', $this->default ) : () ) );
}

sub type { $_[0]->{TYPE} }
sub name { $_[0]->{NAME} }
sub default { $_[0]->{DEFAULT} }
sub has_default { defined $_[0]->{DEFAULT} }

package ExtUtils::XSpp::Node::Type;

use strict;
use base 'ExtUtils::XSpp::Node';

# normalized names for some integral C types
my %normalize =
  ( 'unsigned'           => 'unsigned int',
    'long int'           => 'long',
    'unsigned long int'  => 'unsigned long',
    'short int'          => 'short',
    'unsigned short int' => 'unsigned short',
    );

sub init {
  my $this = shift;
  my %args = @_;

  $this->{BASE} = $normalize{$args{base}} || $args{base};
  $this->{POINTER} = $args{pointer} ? 1 : 0;
  $this->{REFERENCE} = $args{reference} ? 1 : 0;
  $this->{CONST} = $args{const} ? 1 : 0;
  $this->{TEMPLATE_ARGS} = $args{template_args} || [];
}

sub is_const { $_[0]->{CONST} }
sub is_reference { $_[0]->{REFERENCE} }
sub is_pointer { $_[0]->{POINTER} }
sub base_type { $_[0]->{BASE} }
sub template_args { $_[0]->{TEMPLATE_ARGS} }

sub equals {
  my( $f, $s ) = @_;

  return 0 if @{$f->template_args} != @{$s->template_args};

  for( my $i = 0; $i < @{$f->template_args}; ++$i ) {
      return 0
          unless $f->template_args->[$i]->equals( $s->template_args->[$i] );
  }

  return $f->is_const == $s->is_const
      && $f->is_reference == $s->is_reference
      && $f->is_pointer == $s->is_pointer
      && $f->base_type eq $s->base_type;
}

sub is_void { return $_[0]->base_type eq 'void' &&
                !$_[0]->is_pointer && !$_[0]->is_reference }

sub print_tmpl_args {
  my $this = shift;
  my $state = shift;
  my $tmpl_args = '';
  if( @{$this->template_args} ) {
      $tmpl_args =   '< '
                   . join( ', ',
                           map $_->print( $state ), @{$this->template_args} )
                   . ' >';
  }
  return $tmpl_args;
}

sub print {
  my $this = shift;
  my $state = shift;

  return join( '',
               ( $this->is_const ? 'const ' : '' ),
               $this->base_type,
               $this->print_tmpl_args,
               ( $this->is_pointer ? ( '*' x $this->is_pointer ) :
                 $this->is_reference ? '&' : '' ) );
}


package ExtUtils::XSpp::Node::Module;

use strict;
use base 'ExtUtils::XSpp::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{MODULE} = $args{module};
}

sub module { $_[0]->{MODULE} }
sub to_string { 'MODULE=' . $_[0]->module }
sub print { return $_[0]->to_string . "\n" }

package ExtUtils::XSpp::Node::File;

use strict;
use base 'ExtUtils::XSpp::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{FILE} = $args{file};
}

sub file { $_[0]->{FILE} }
sub print { "\n" }

1;
