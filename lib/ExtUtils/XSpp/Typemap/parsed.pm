package ExtUtils::XSpp::Typemap::parsed;

use base 'ExtUtils::XSpp::Typemap';

sub _dl { return defined( $_[0] ) && length( $_[0] ) ? $_[0] : undef }

sub init {
  my $this = shift;
  my %args = @_;

  $this->{TYPE} = $args{type};
  $this->{CPP_TYPE} = $args{cpp_type} || $args{arg1};
  $this->{CALL_FUNCTION_CODE} = _dl( $args{call_function_code} || $args{arg2} );
  $this->{OUTPUT_CODE} = _dl( $args{output_code} || $args{arg3} );
  $this->{CLEANUP_CODE} = _dl( $args{cleanup_code} || $args{arg4} );
  $this->{PRECALL_CODE} = _dl( $args{precall_code} || $args{arg5} );
}

sub cpp_type { $_[0]->{CPP_TYPE} }
sub output_code { $_[0]->{OUTPUT_CODE} }
sub cleanup_code { $_[0]->{CLEANUP_CODE} }
sub call_parameter_code { undef }
sub call_function_code {
  my( $this, $func, $var ) = @_;
  return unless defined $this->{CALL_FUNCTION_CODE};
  return _replace( $this->{CALL_FUNCTION_CODE}, '$1' => $func, '$$' => $var );
}

sub precall_code {
  my( $this, $pvar, $cvar ) = @_;
  return unless defined $_[0]->{PRECALL_CODE};
  return _replace( $this->{PRECALL_CODE}, '$1' => $pvar, '$2' => $cvar );
}

sub _replace {
  my( $code ) = shift;
  while( @_ ) {
    my( $f, $t ) = ( shift, shift );
    $code =~ s/\Q$f\E/$t/g;
  }
  return $code;
}

1;
