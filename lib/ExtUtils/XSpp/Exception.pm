package ExtUtils::XSpp::Exception;
use strict;
use warnings;

#require ExtUtils::XSpp::Exception::simple;
#require ExtUtils::XSpp::Exception::stdmessage;
#require ExtUtils::XSpp::Exception::message;
#require ExtUtils::XSpp::Exception::object;

=head1 NAME

ExtUtils::XSpp::Exception - Map C++ exceptions to Perl exceptions

=head1 DESCRIPTION

This class is both the base class for the different exception handling
mechanisms and the container for the global set of exception
mappings from C++ exceptions (indicated by a data type to catch)
to Perl exceptions. The Perl exceptions are implemented via C<croak()>.
There are different cases of Perl exceptions that are implemented
as sub-classes of C<ExtUtils::XSpp::Exception>:

=over 2

=item L<ExtUtils::XSpp::Exception::simple>

implements the most general case of simply throwing a
generic error message that includes the name of the
C++ exception type.

=item L<ExtUtils::XSpp::Exception::stdmessage>

handles C++ exceptions that are derived from C<std::exception> and
which provide a C<char* what()> method that will provide an error message.
The Perl-level error message will include the C++ exception type name
and the exception's C<what()> message.

=item L<ExtUtils::XSpp::Exception::message>

translate C++ exceptions to Perl error messages using a printf-like
mask for the message. Potentially by calling methods on the
C++ exception object(!). Details to be hammered out.

=item L<ExtUtils::XSpp::Exception::object>

maps C++ exceptions to throwing an instance of some Perl exception class.
Details to be hammered out.

=cut

sub new {
  my $class = shift;
  my $this = bless {}, $class;

  $this->init( @_ );

  return $this;
}

=head2 ExtUtils::XSpp::Exception::type

Returns the ExtUtils::XSpp::Node::Type that is used for this Exception.

=cut

sub type { $_[0]->{TYPE} }

=head2 ExtUtils::XSpp::Exception::cpp_type()

Returns the C++ type to be used for the local variable declaration.

=head2 ExtUtils::XSpp::Exception::input_code( perl_argument_name, cpp_var_name1, ... )

Code to put the contents of the perl_argument (typically ST(x)) into
the C++ variable(s).

=head2 ExtUtils::XSpp::Exception::output_code()

=head2 ExtUtils::XSpp::Exception::cleanup_code()

=head2 ExtUtils::XSpp::Exception::call_parameter_code( parameter_name )

=head2 ExtUtils::XSpp::Exception::call_function_code( function_call_code, return_variable )

=cut

sub init { }

sub cpp_type { die; }
sub input_code { die; }
sub precall_code { undef }
sub output_code { undef }
sub cleanup_code { undef }
sub call_parameter_code { undef }
sub call_function_code { undef }

my @Exceptions;

# add Exceptions for basic C types
add_default_Exceptions();

sub add_Exception_for_type {
  my( $type, $Exception ) = @_;

  unshift @Exceptions, [ $type, $Exception ];
}

# a weak Exception does not override an already existing Exception for the
# same type
sub add_weak_Exception_for_type {
  my( $type, $Exception ) = @_;

  foreach my $t ( @Exceptions ) {
    return if $t->[0]->equals( $type );
  }
  unshift @Exceptions, [ $type, $Exception ];
}

sub get_Exception_for_type {
  my $type = shift;

  foreach my $t ( @Exceptions ) {
    return ${$t}[1] if $t->[0]->equals( $type );
  }

  Carp::confess( "No Exception for type ", $type->print );
}

sub add_default_Exceptions {
  # void, integral and floating point types
  foreach my $t ( 'char', 'short', 'int', 'long',
                  'unsigned char', 'unsigned short', 'unsigned int',
                  'unsigned long', 'void',
                  'float', 'double', 'long double' ) {
    my $type = ExtUtils::XSpp::Node::Type->new( base => $t );

    ExtUtils::XSpp::Exception::add_Exception_for_type
        ( $type, ExtUtils::XSpp::Exception::simple->new( type => $type ) );
  }

  # char*, const char*
  my $char_p = ExtUtils::XSpp::Node::Type->new
                   ( base    => 'char',
                     pointer => 1,
                     );

  ExtUtils::XSpp::Exception::add_Exception_for_type
      ( $char_p, ExtUtils::XSpp::Exception::simple->new( type => $char_p ) );

  my $const_char_p = ExtUtils::XSpp::Node::Type->new
                         ( base    => 'char',
                           pointer => 1,
                           const   => 1,
                           );

  ExtUtils::XSpp::Exception::add_Exception_for_type
      ( $const_char_p, ExtUtils::XSpp::Exception::simple->new( type => $const_char_p ) );
}

1;
