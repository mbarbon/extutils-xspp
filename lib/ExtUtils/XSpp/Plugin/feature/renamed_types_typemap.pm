package ExtUtils::XSpp::Plugin::feature::renamed_types_typemap;

use strict;
use warnings;

sub register_plugin {
    my( $class, $parser ) = @_;

    ExtUtils::XSpp::Typemap::_enable_renamed_types_typemaps();
    ExtUtils::XSpp::Node::Class::_enable_renamed_types_typemaps();
}

1;
