package ExtUtils::XSpp::Node;
use strict;
use warnings;
use Carp ();

=head1 NAME

ExtUtils::XSpp::Node - Base class for elements of the parser output

=head1 DESCRIPTION

ExtUtils::XSpp::Node is a base class for all elements of the
parser's output.

=head1 METHODS

=head2 new

Calls the C<$self->init(@_)> method after construction.
Override C<init()> in subclasses.

=cut

sub new {
  my $class = shift;
  my $this = bless {}, $class;

  $this->init( @_ );

  return $this;
}

=head2 init

Called by the constructor. Every sub-class needs to override this.

=cut

sub init {
  my $self = shift;
  Carp::croak(
    "Programmer was too lazy to implement init() in her Node sub-class"
  );
}

=head2 ExtUtils::XSpp::Node::print

Return a string to be output in the final XS file.
Every sub-class must override this method.

=cut

sub print {
  my $self = shift;
  Carp::croak(
    "Programmer was too lazy to implement print() in her Node sub-class"
  );
}


1;
