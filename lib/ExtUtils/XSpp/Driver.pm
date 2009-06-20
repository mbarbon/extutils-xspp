package ExtUtils::XSpp::Driver;

use strict;
use warnings;

use File::Basename ();
use File::Path ();

use ExtUtils::XSpp::Parser;

sub new {
    my( $class, %args ) = @_;
    my $self = bless \%args, $class;

    return $self;
}

sub generate {
    my( $self ) = @_;

    foreach my $typemap ( $self->typemaps ) {
        ExtUtils::XSpp::Parser->new( file => $typemap )->parse;
    }

    my $parser = ExtUtils::XSpp::Parser->new( file   => $self->file,
                                              string => $self->string,
                                              );
    my $success = $parser->parse;
    return() if not $success;

    return $self->_emit( $parser );
}

sub process {
    my( $self ) = @_;

    my $generated = $self->generate;
    return() if not $generated;
    $self->_write( $generated );
}

sub _write {
    my( $self, $out ) = @_;

    foreach my $f ( keys %$out ) {
        if( $f eq '-' ) {
            print $$out{$f};
        } else {
            File::Path::mkpath( File::Basename::dirname( $f ) );

            open my $fh, '>', $f or die "open '$f': $!";
            binmode $fh;
            print $fh $$out{$f};
            close $fh or die "close '$f': $!";
        }
    }
    return 1;
}

sub _emit {
    my( $self, $parser ) = @_;
    my $data = $parser->get_data;
    my %out;
    my $out_file = '-';
    my %state = ( current_module => undef );

    foreach my $e ( @$data ) {
        if( $e->isa( 'ExtUtils::XSpp::Node::Module' ) ) {
            $state{current_module} = $e;
        }
        if( $e->isa( 'ExtUtils::XSpp::Node::File' ) ) {
            $out_file = $e->file;
        }
        $out{$out_file} .= $e->print( \%state );
    }

    return \%out;
}

sub typemaps { @{$_[0]->{typemaps} || []} }
sub file     { $_[0]->{file} }
sub string   { $_[0]->{string} }
sub output   { $_[0]->{output} }

1;
