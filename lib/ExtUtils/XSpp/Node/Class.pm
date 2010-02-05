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

1;