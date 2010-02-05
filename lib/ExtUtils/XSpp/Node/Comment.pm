package ExtUtils::XSpp::Node::Comment;

=head1 ExtUtils::XSpp::Node::Comment

Contains data that should be output prefixed with a comment marker

=cut

use strict;
use base 'ExtUtils::XSpp::Node::Raw';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{ROWS} = $args{rows};
}

sub print {
  my $this = shift;
  my $state = shift;

  return "\n";
}

1;