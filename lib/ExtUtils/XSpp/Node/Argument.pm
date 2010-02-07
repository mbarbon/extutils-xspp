package ExtUtils::XSpp::Node::Argument;
use strict;
use warnings;
use base 'ExtUtils::XSpp::Node';

=head1 NAME

ExtUtils::XSpp::Node::Argument - Node representing a method/function argument

=head1 DESCRIPTION

An L<ExtUtils::XSpp::Node> subclass representing a single function
or method argument such as

  int foo = 0.

which would translate to an C<ExtUtils::XSpp::Node::Argument> which has
its C<type> set to C<int>, its C<name> set to C<foo> and its C<default>
set to C<0.>.

=head1 METHODS

=head2 new

Creates a new C<ExtUtils::XSpp::Node::Argument>.

Named parameters: C<type> indicating the C++ argument type,
C<name> indicating the variable name, and optionally
C<default> indicating the default value of the argument.

=cut

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

=head1 ACCESSORS

=head2 type

Returns the type of the argument.

=head2 name

Returns the variable name of the argument variable.

=head2 default

Returns the default for the function parameter if any.

=head2 has_default

Returns whether there is a default for the function parameter.

=cut

sub type { $_[0]->{TYPE} }
sub name { $_[0]->{NAME} }
sub default { $_[0]->{DEFAULT} }
sub has_default { defined $_[0]->{DEFAULT} }

1;
