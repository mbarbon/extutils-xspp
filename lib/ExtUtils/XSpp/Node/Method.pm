package ExtUtils::XSpp::Node::Method;
use strict;
use warnings;
use base 'ExtUtils::XSpp::Node::Function';

=head1 NAME

ExtUtils::XSpp::Node::Method - Node representing a method

=head1 DESCRIPTION

An L<ExtUtils::XSpp::Node::Function> sub-class representing a single method
declaration in a class such as

  class FooBar {
    int foo(double someArgument); // <-- this one
  }


=head1 METHODS

=head2 new

Creates a new C<ExtUtils::XSpp::Node::Argument>.

Most of the functionality of this class is inherited. This
means that all named parameters of L<ExtUtils::XSpp::Node::Function>
are also valid for this class.

=cut

=head2 perl_function_name

Returns the name of the Perl function (method) that this
method represents. It is constructed from the method's
class's name and the C<perl_name> attribute.

=cut

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

=head2 is_method

Returns true, since all objects of this class are methods.

=cut

sub is_method { 1 }

=head2 ACCESSORS

=head2 class

Returns the class (L<ExtUtils::XSpp::Node::Class>) that the
method belongs to.

=cut

sub class { $_[0]->{CLASS} }


1;
