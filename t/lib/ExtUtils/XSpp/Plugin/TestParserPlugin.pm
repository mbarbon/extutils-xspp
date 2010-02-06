package ExtUtils::XSpp::Plugin::TestParserPlugin;

use strict;
use warnings;

sub new { return bless {}, $_[0] }

sub register_plugin {
    my( $class, $parser ) = @_;
    my $inst = $class->new;

    $parser->add_function_tag_plugin( $inst );
    $parser->add_class_tag_plugin( $inst );
    $parser->add_method_tag_plugin( $inst );
}

sub handle_method_tag {
    my( $self, $method, $any_tag, %args ) = @_;
    my $name = $args{any_special_block}[0];

    $method->set_perl_name( $name );

    1;
}

sub handle_function_tag {
    my( $self, $function, $any_tag, %args ) = @_;
    my $name = $args{any_special_block}[0];

    $function->set_perl_name( $name );

    return 1;
}

sub handle_class_tag {
    my( $self, $class, $any_tag, %args ) = @_;
    my $name = $args{any_special_block}[0];

    $class->set_perl_name( $name );

    return 1;
}

1;
