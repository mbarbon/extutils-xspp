package ExtUtils::XSpp::Node::Raw;

=head1 ExtUtils::XSpp::Node::Raw

Contains data that should be output "as is" in the destination file.

=cut

use strict;
use base 'ExtUtils::XSpp::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{ROWS} = $args{rows};
  push @{$this->{ROWS}}, "\n";
}

=head2 ExtUtils::XSpp::Node::Raw::rows

Returns an array reference holding the rows to be output in the final file.

=cut

sub rows { $_[0]->{ROWS} }
sub print { join( "\n", @{$_[0]->rows} ) . "\n" }

1;