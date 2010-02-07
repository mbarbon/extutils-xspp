package ExtUtils::XSpp::Exception;
use strict;
use warnings;

require ExtUtils::XSpp::Exception::unknown;
require ExtUtils::XSpp::Exception::simple;
require ExtUtils::XSpp::Exception::stdmessage;
#require ExtUtils::XSpp::Exception::message;
#require ExtUtils::XSpp::Exception::object;

=head1 NAME

ExtUtils::XSpp::Exception - Map C++ exceptions to Perl exceptions

=head1 DESCRIPTION

This class is both the base class for the different exception handling
mechanisms and the container for the global set of exception
mappings from C++ exceptions (indicated by a C++ data type to catch)
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

translates C++ exceptions to Perl error messages using a printf-like
mask for the message. Potentially filling in place-holders by calling
methods on the C++ exception object(!). Details to be hammered out.

=item L<ExtUtils::XSpp::Exception::object>

maps C++ exceptions to throwing an instance of some Perl exception class.
Details to be hammered out.

=item L<ExtUtils::XSpp::Exception::unknown>

is the default exception handler that is added to the list of handlers
automatically during code generation. It simply throws an entirely
unspecific error and catches the type C<...> (meaning: anything).

=back

The basic idea is that you can declare the C++ exception types that
you want to handle and how you plan to do so by using the C<%exception>
directive in your XS++ (or rather XS++ typemap!):

  // OutOfBoundsException would have been declared
  // elsewhere as:
  //
  // class OutOfBoundsException : public std::exception {
  // public:
  //   OutOfBoundsException() {}
  //   virtual const char* what() const throw() {
  //     return "You accessed me out of bounds, fool!";
  //   }
  // }
  
  // tentative syntax...
  %exception{outOfBounds}{OutOfBoundsException}{stdmessage};

If you know a function or method may throw C<MyOutOfBoundsException>s, you
can annotate the declaration in your XS++ as follows:

  // tentative syntax...
  double get_from_array(unsigned int index)
    %catch{outOfBounds};

When C<get_from_array> now throws an C<OutOfBoundsException>, the user
gets a Perl croak with the message
C<"Caught exception of type 'OutOfBoundsException': You accessed me out of bounds, fool!">.

I<Note:> Why do we assign another name (C<outOfBounds>) to the
existing C<OutOfBoundsException>?
Because you may need to catch exceptions of the same C++ type with different
handlers for different methods. You can, in principle, re-use the C++ exception
class name for the exception I<map> name, but that may be confusing to posterity.

If there are no C<%catch> decorators on a method, exceptions derived
from C<std::exception> will be caught with a generic C<stdmessage>
handler such as above (FIXME, implement).
Even if there are C<%catch> clauses for the given method,
all otherwise uncaught exceptions will be caught with a generic error message
for safety.

=head1 METHODS

=cut

=head2 new

Creates a new C<ExtUtils::XSpp::Exception>.

Calls the C<$self->init(@_)> method after construction.
C<init()> must be overridden in subclasses.

=cut

sub new {
  my $class = shift;
  my $this = bless {}, $class;

  $this->init( @_ );

  return $this;
}

sub init {
  my $self = shift;
  my %args = @_;
  $self->{TYPE} = $args{type};
  $self->{NAME} = $args{name};
}

=head2 handler_code

Unimplemented in this base class, but must be implemented
in all actual exception classes.

Generates the C<catch(){}> block of code for inclusion
in the XS output. First (optional) argument is an integer indicating
the number of spaces to use for the first indentation level.

=cut

sub handler_code {
  Carp::croak("Programmer left 'handler_code' method of his Exception subclass unimplemented");  
}

=head2 indent_code

Given a piece of code and a number of spaces to use for
global indentation, indents the code and returns it.

=cut

sub indent_code {
  my $this = shift;
  my $code = shift;
  my $n = shift;
  my $indent = " " x $n;
  $code =~ s/^/$indent/gm;
  return $code;
}

=head2 cpp_type

Fetches the C++ type of the exception from the C<type> attribute and returns it.

=cut

# TODO: Strip pointers and references
sub cpp_type {
  my $this = shift;
  return $this->type->print;
}

=head1 ACCESSORS

=head2 name

Returns the name of the exception.
This is the C<myException> in C<%exception{myException}{char*}{handler}>.

=cut

sub name { $_[0]->{NAME} }

=head2 type

Returns the L<ExtUtils::XSpp::Node::Type> C++ type that is used for this exception.
This is the C<char*> in C<%exception{myException}{char*}{handler}>.

=cut

sub type { $_[0]->{TYPE} }


=head1 CLASS METHODS

=cut

my %ExceptionsByName;
#my %ExceptionsByType;

=head2 add_exception

Given an C<ExtUtils::XSpp::Exception> object,
adds this object to the global registry, potentially
overwriting an exception map of the same name that was
in effect before.

=cut

sub add_exception {
  my ($class, $exception) = @_;

  $ExceptionsByName{$exception->name} = $exception;
  #push @{$ExceptionsByType{$exception->print} }, $exception;
  return();
}

=head2 get_exception_for_name

Given the XS++ name of the exception map, fetches
the corresponding C<ExtUtils::XSpp::Exception> object
from the global registry and returns it. Croaks on error.

=cut

sub get_exception_for_name {
  my ($class, $name) = @_;

  if (not exists $ExceptionsByName{$name}) {
    Carp::confess( "No Exception with the name $name declared" );
  }
  return $ExceptionsByName{$name};
}


1;
