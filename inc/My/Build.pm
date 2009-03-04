package My::Build;

use strict;
use warnings;
use base qw(Module::Build);

sub ACTION_code {
    my( $self ) = @_;

    if( !$self->up_to_date( [ 'XSP.yp' ],
                            [ 'lib/ExtUtils/XSpp/Grammar.pm' ] ) ) {
        $self->do_system( 'yapp', '-v', '-m', 'ExtUtils::XSpp::Grammar',
                          '-o', 'lib/ExtUtils/XSpp/Grammar.pm', 'XSP.yp' );
    }

    $self->SUPER::ACTION_code;
}

1;
