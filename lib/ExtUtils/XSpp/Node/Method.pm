package ExtUtils::XSpp::Node::Method;

use strict;
use base 'ExtUtils::XSpp::Node::Function';

sub class { $_[0]->{CLASS} }
sub perl_function_name { $_[0]->class->cpp_name . '::' .
                         $_[0]->perl_name }
sub _call_code {
    my( $self ) = @_;

    if( $self->package_static ) {
        return $_[0]->class->cpp_name . '::' .
               $_[0]->cpp_name . '(' . $_[1] . ')';
    } else {
        return "THIS->" .
               $_[0]->cpp_name . '(' . $_[1] . ')';
    }
}

sub is_method { 1 }

1;