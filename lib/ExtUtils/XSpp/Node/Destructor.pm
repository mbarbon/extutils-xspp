package ExtUtils::XSpp::Node::Destructor;

use strict;
use base 'ExtUtils::XSpp::Node::Method';

sub init {
  my $this = shift;
  $this->SUPER::init( @_ );

  die "Can't specify return value in destructor" if $this->{RET_TYPE};
}

sub perl_function_name { $_[0]->class->cpp_name . '::' . 'DESTROY' }
sub ret_type { undef }

1;