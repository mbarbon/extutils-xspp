package ExtUtils::XSpp::Node::File;

use strict;
use base 'ExtUtils::XSpp::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{FILE} = $args{file};
}

sub file { $_[0]->{FILE} }
sub print { "\n" }

1;