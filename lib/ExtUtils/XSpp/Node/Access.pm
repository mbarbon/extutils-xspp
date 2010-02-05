package ExtUtils::XSpp::Node::Access;

=head1 ExtUtils::XSpp::Node::Access

Access specifier.

=cut

use strict;
use base 'ExtUtils::XSpp::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{ACCESS} = $args{access};
}

sub access { $_[0]->{ACCESS} }

1;