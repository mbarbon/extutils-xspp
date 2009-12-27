package ExtUtils::XSpp::Typemap;

=head1 NAME

ExtUtils::XSpp::Typemap - map types

=cut

use strict;
use warnings;

sub new {
  my $class = shift;
  my $this = bless {}, $class;

  $this->init( @_ );

  return $this;
}

=head2 ExtUtils::XSpp::Typemap::type

Returns the ExtUtils::XSpp::Node::Type that is used for this typemap.

=cut

sub type { $_[0]->{TYPE} }

=head2 ExtUtils::XSpp::Typemap::cpp_type()

Returns the C++ type to be used for the local variable declaration.

=head2 ExtUtils::XSpp::Typemap::input_code( perl_argument_name, cpp_var_name1, ... )

Code to put the contents of the perl_argument (typically ST(x)) into
the C++ variable(s).

=head2 ExtUtils::XSpp::Typemap::output_code()

=head2 ExtUtils::XSpp::Typemap::cleanup_code()

=head2 ExtUtils::XSpp::Typemap::call_parameter_code( parameter_name )

=head2 ExtUtils::XSpp::Typemap::call_function_code( function_call_code, return_variable )

=cut

sub init { }

sub cpp_type { die; }
sub input_code { die; }
sub precall_code { undef }
sub output_code { undef }
sub cleanup_code { undef }
sub call_parameter_code { undef }
sub call_function_code { undef }

my @typemaps;

# add typemaps for basic C types
add_default_typemaps();

sub add_typemap_for_type {
  my( $type, $typemap ) = @_;

  unshift @typemaps, [ $type, $typemap ];
}

# a weak typemap does not override an already existing typemap for the
# same type
sub add_weak_typemap_for_type {
  my( $type, $typemap ) = @_;

  foreach my $t ( @typemaps ) {
    return if $t->[0]->equals( $type );
  }
  unshift @typemaps, [ $type, $typemap ];
}

sub get_typemap_for_type {
  my $type = shift;

  foreach my $t ( @typemaps ) {
    return ${$t}[1] if $t->[0]->equals( $type );
  }

  Carp::confess( "No typemap for type ", $type->print );
}

sub add_default_typemaps {
  # void, integral and floating point types
  foreach my $t ( 'char', 'short', 'int', 'long',
                  'unsigned char', 'unsigned short', 'unsigned int',
                  'unsigned long', 'void',
                  'float', 'double', 'long double' ) {
    my $type = ExtUtils::XSpp::Node::Type->new( base => $t );

    ExtUtils::XSpp::Typemap::add_typemap_for_type
        ( $type, ExtUtils::XSpp::Typemap::simple->new( type => $type ) );
  }

  # char*, const char*
  my $char_p = ExtUtils::XSpp::Node::Type->new
                   ( base    => 'char',
                     pointer => 1,
                     );

  ExtUtils::XSpp::Typemap::add_typemap_for_type
      ( $char_p, ExtUtils::XSpp::Typemap::simple->new( type => $char_p ) );

  my $const_char_p = ExtUtils::XSpp::Node::Type->new
                         ( base    => 'char',
                           pointer => 1,
                           const   => 1,
                           );

  ExtUtils::XSpp::Typemap::add_typemap_for_type
      ( $const_char_p, ExtUtils::XSpp::Typemap::simple->new( type => $const_char_p ) );
}

package ExtUtils::XSpp::Typemap::parsed;

use base 'ExtUtils::XSpp::Typemap';

sub _dl { return defined( $_[0] ) && length( $_[0] ) ? $_[0] : undef }

sub init {
  my $this = shift;
  my %args = @_;

  $this->{TYPE} = $args{type};
  $this->{CPP_TYPE} = $args{cpp_type} || $args{arg1};
  $this->{CALL_FUNCTION_CODE} = _dl( $args{call_function_code} || $args{arg2} );
  $this->{OUTPUT_CODE} = _dl( $args{output_code} || $args{arg3} );
  $this->{CLEANUP_CODE} = _dl( $args{cleanup_code} || $args{arg4} );
  $this->{PRECALL_CODE} = _dl( $args{precall_code} || $args{arg5} );
}

sub cpp_type { $_[0]->{CPP_TYPE} }
sub output_code { $_[0]->{OUTPUT_CODE} }
sub cleanup_code { $_[0]->{CLEANUP_CODE} }
sub call_parameter_code { undef }
sub call_function_code {
  my( $this, $func, $var ) = @_;
  return unless defined $this->{CALL_FUNCTION_CODE};
  return _replace( $this->{CALL_FUNCTION_CODE}, '$1' => $func, '$$' => $var );
}

sub precall_code {
  my( $this, $pvar, $cvar ) = @_;
  return unless defined $_[0]->{PRECALL_CODE};
  return _replace( $this->{PRECALL_CODE}, '$1' => $pvar, '$2' => $cvar );
}

sub _replace {
  my( $code ) = shift;
  while( @_ ) {
    my( $f, $t ) = ( shift, shift );
    $code =~ s/\Q$f\E/$t/g;
  }
  return $code;
}

package ExtUtils::XSpp::Typemap::simple;

use base 'ExtUtils::XSpp::Typemap';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{TYPE} = $args{type};
}

sub cpp_type { $_[0]->{TYPE}->print }
sub output_code { undef } # likewise
sub call_parameter_code { undef }
sub call_function_code { undef }

package ExtUtils::XSpp::Typemap::reference;

use base 'ExtUtils::XSpp::Typemap';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{TYPE} = $args{type};
}

sub cpp_type { $_[0]->{TYPE}->base_type . '*' }
sub output_code { undef }
sub call_parameter_code { "*( $_[1] )" }
sub call_function_code {
  $_[2] . ' = new ' . $_[0]->type->base_type . '( ' . $_[1] . " )";
}

1;
