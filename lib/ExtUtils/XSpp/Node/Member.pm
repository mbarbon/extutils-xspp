package ExtUtils::XSpp::Node::Member;
use strict;
use warnings;
use Carp ();
use base 'ExtUtils::XSpp::Node';

=head1 NAME

ExtUtils::XSpp::Node::Member - Node representing a class member variable

=head1 DESCRIPTION

An L<ExtUtils::XSpp::Node> sub-class representing a single member
variable in a class such as

  class FooBar {
    int foo; // <-- this one
  }


=head1 METHODS

=head2 new

Creates a new C<ExtUtils::XSpp::Node::Member>.

Named parameters: C<cpp_name> indicating the C++ name of the member,
C<perl_name> indicating the Perl name of the member (defaults to the
same as C<cpp_name>), C<type> indicates the (C++) type of the member
and finally C<class>, which is an L<ExtUtils::XSpp::Node::Class>.

=cut

sub init {
  my $this = shift;
  my %args = @_;

  $this->{CPP_NAME}  = $args{cpp_name};
  $this->{PERL_NAME} = $args{perl_name} || $args{cpp_name};
  $this->{TYPE}      = $args{type};
  $this->{CLASS}     = $args{class};
  $this->{CONDITION} = $args{condition};
  $this->{TAGS}      = $args{tags};
  $this->{EMIT_CONDITION} = $args{emit_condition};
}

sub print {
  my( $this, $state ) = @_;

  # no standard way of emitting a member
  ''
}

=head2 resolve_typemaps

Fetches the L<ExtUtils::XSpp::Typemap> object for the type
from the typemap registry and stores a reference to the object.

=cut

sub resolve_typemaps {
  my $this = shift;

  $this->{TYPEMAPS}{TYPE} ||=
      ExtUtils::XSpp::Typemap::get_typemap_for_type( $this->type );
}

=head1 ACCESSORS

=head2 cpp_name

Returns the C++ name of the member.

=head2 perl_name

Returns the Perl name of the member (defaults to same as C++).

=head2 set_perl_name

Sets the Perl name of the member.

=head2 type

Returns the C++ type for the member.

=head2 class

Returns the class (L<ExtUtils::XSpp::Node::Class>) that the
member belongs to.

=head2 access

Returns C<'public'>, C<'protected'> or C<'private'> depending on
member access declaration.

=cut

sub cpp_name { $_[0]->{CPP_NAME} }
sub set_cpp_name { $_[0]->{CPP_NAME} = $_[1] }
sub perl_name { $_[0]->{PERL_NAME} }
sub set_perl_name { $_[0]->{PERL_NAME} = $_[1] }
sub type { $_[0]->{TYPE} }
sub tags { $_[0]->{TAGS} }
sub class { $_[0]->{CLASS} }
sub access { $_[0]->{ACCESS} }
sub set_access { $_[0]->{ACCESS} = $_[1] }

=head2 typemap

Returns the typemap for member type.

=head2 set_typemap( typemap )

Sets the typemap for member type.

=cut

sub typemap {
  my ($this) = @_;

  die "Typemap not available yet" unless $this->{TYPEMAPS}{TYPE};
  return $this->{TYPEMAPS}{TYPE};
}

sub set_typemap {
  my ($this, $typemap) = @_;

  $this->{TYPEMAPS}{TYPE} = $typemap;
}

1;
