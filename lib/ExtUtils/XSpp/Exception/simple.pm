package ExtUtils::XSpp::Exception::simple;

use base 'ExtUtils::XSpp::Exception';

sub init {
  my $this = shift;
  $this->SUPER::init(@_);
}

sub handler_code {
  my $this = shift;
  my $no_spaces_indent = shift;
  $no_spaces_indent = 4 if not defined $no_spaces_indent;

  my $msg = "Caught C++ exception of type '$ctype'";
  return <<HERE;
catch ($ctype& e) {
  croak("$msg");
}
HERE
  return $this->indent_code($code, $no_spaces_indent);
}

1;
