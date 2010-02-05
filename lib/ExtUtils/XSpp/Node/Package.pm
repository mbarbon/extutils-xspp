package ExtUtils::XSpp::Node::Package;

=head1 ExtUtils::XSpp::Node::Package

Used to put global functions inside a Perl package.

=cut

use strict;
use base 'ExtUtils::XSpp::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{CPP_NAME} = $args{cpp_name};
  $this->{PERL_NAME} = $args{perl_name} || $args{cpp_name};
}

=head2 ExtUtils::XSpp::Node::Package::cpp_name

Returns the C++ name for the package (will be used for namespaces).

=head2 ExtUtils::XSpp::Node::Package::perl_name

Returns the Perl name for the package.

=cut

sub cpp_name { $_[0]->{CPP_NAME} }
sub perl_name { $_[0]->{PERL_NAME} }
sub set_perl_name { $_[0]->{PERL_NAME} = $_[1] }

sub print {
  my $this = shift;
  my $state = shift;
  my $out = '';
  my $pcname = $this->perl_name;

  if( !defined $state->{current_module} ) {
    die "No current module: remember to add a %module{} directive";
  }
  my $cur_module = $state->{current_module}->to_string;

  $out .= <<EOT;

$cur_module PACKAGE=$pcname

EOT

  return $out;
}

1;