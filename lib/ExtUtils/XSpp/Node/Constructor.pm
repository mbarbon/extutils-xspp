package ExtUtils::XSpp::Node::Constructor;

use strict;
use base 'ExtUtils::XSpp::Node::Method';

sub init {
  my $this = shift;
  $this->SUPER::init( @_ );

  die "Can't specify return value in constructor" if $this->{RET_TYPE};
}

sub ret_type {
  my $this = shift;

  ExtUtils::XSpp::Node::Type->new( base      => $this->class->cpp_name,
                            pointer   => 1 );
}

sub perl_function_name {
  my $this = shift;
  my( $pname, $cname, $pclass, $cclass ) = ( $this->perl_name,
                                             $this->cpp_name,
                                             $this->class->perl_name,
                                             $this->class->cpp_name );

  if( $pname ne $cname ) {
    return $cclass . '::' . $pname;
  } else {
    return $cclass . '::' . 'new';
  }
}

sub _call_code { return "new " . $_[0]->class->cpp_name .
                   '(' . $_[1] . ')'; }

1;