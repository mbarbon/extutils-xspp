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

1;