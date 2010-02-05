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

1;
