package ExtUtils::XSpp::Node::Class;
use strict;
use warnings;
use base 'ExtUtils::XSpp::Node::Package';

=head1 NAME

ExtUtils::XSpp::Node::Class - A class (inherits from Package).

=head1 DESCRIPTION

An L<ExtUtils::XSpp::Node::Package> sub-class representing a class
declaration such as

  %name{PerlClassName} class MyClass : public BaseClass
  {
    ...
  }

The Perl-level class name and the C++ class name attributes
are inherited from the L<ExtUtils::XSpp::Node::Package> class.

=head1 METHODS

=head2 new

Creates a new C<ExtUtils::XSpp::Node::Class> object.

Optional named parameters:
C<methods> can be a reference to an array of methods
(L<ExtUtils::XSpp::Node::Method>) of the class,
and C<base_classes>, a reference to an array of
base classes (C<ExtUtils::XSpp::Node::Class> objects).
C<catch> may be a list of exception names that all
methods in the class handle.

=cut

sub init {
  my $this = shift;
  my %args = @_;

  $this->SUPER::init( @_ );
  $this->{METHODS} = [];
  $this->{BASE_CLASSES} = $args{base_classes} || [];
  $this->add_methods( @{$args{methods}} ) if $args{methods};
  $this->{CATCH}     = $args{catch};
}

=head2 add_methods

Adds new methods to the class. By default, their
scope is C<public>. Takes arbitrary number of arguments
which are processed in order.

If an argument is an L<ExtUtils::XSpp::Node::Access>,
the current method scope is changed accordingly for
all following methods.

If an argument is an L<ExtUtils::XSpp::Node::Method>,
it is added to the list of methods of the class.
The method's class name is set to the current class
and its scope is set to the current method scope.

=cut

sub add_methods {
  my $this = shift;
  my $access = 'public'; # good enough for now
  foreach my $meth ( @_ ) {
      if( $meth->isa( 'ExtUtils::XSpp::Node::Method' ) ) {
          $meth->{CLASS} = $this;
          $meth->{ACCESS} = $access;
          $meth->add_exception_handlers( @{$this->{CATCH} || []} );
          $meth->resolve_typemaps;
          $meth->resolve_exceptions;
      } elsif( $meth->isa( 'ExtUtils::XSpp::Node::Access' ) ) {
          $access = $meth->access;
          next;
      }
      # FIXME: Should there be else{croak}?
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

=head1 ACCESSORS

=head2 methods

Returns the internal reference to the array of methods in this class.
Each of the methods is an C<ExtUtils::XSpp::Node::Method>

=head2 base_classes

Returns the internal reference to the array of base classes of
this class.

=cut

sub methods { $_[0]->{METHODS} }
sub base_classes { $_[0]->{BASE_CLASSES} }

1;
