package ExtUtils::XSpp::Node::Module;

use strict;
use base 'ExtUtils::XSpp::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{MODULE} = $args{module};
}

sub module { $_[0]->{MODULE} }
sub to_string { 'MODULE=' . $_[0]->module }
sub print { return $_[0]->to_string . "\n" }

1;