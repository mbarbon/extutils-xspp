package ExtUtils::XSpp::Exception::simple;

use base 'ExtUtils::XSpp::Exception';

sub init {
  my $this = shift;
  $this->SUPER::init(@_);
  my %args = @_;
  $this->{TYPE} = $args{type};
}

sub handler_code {
  my $this = shift;
  my $ctype = $this->cpp_type;
  my $msg = "Caught C++ exception of type '$ctype'";
  return <<HERE
  catch ($ctype& e) {
    croak("$msg");
  }
HERE
}

1;
