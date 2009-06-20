package ExtUtils::XSpp::Parser;

use strict;
use warnings;

use IO::Handle;
use ExtUtils::XSpp::Grammar;

=head1 NAME

ExtUtils::XSpp::Parser - an XS++ parser

=cut

sub _my_open {
  my $file = shift;

  open my $in, "<", $file
    or die "Failed to open '$file' for reading: $!";

  return $in;
}

=head2 ExtUtils::XSpp::Parser::new( file => path )

Create a new XS++ parser.

=cut

sub new {
  my $class = shift;
  my $this = bless {}, $class;
  my %args = @_;

  $this->{FILE} = $args{file};
  $this->{STRING} = $args{string};
  $this->{PARSER} = ExtUtils::XSpp::Grammar->new;

  return $this;
}

=head2 ExtUtils::XSpp::Parser::parse

Parse the file data; returns true on success, false otherwise,
on failure C<get_errors> will return the list of errors.

=cut

sub parse {
  my $this = shift;
  my $fh;
  if( $this->{FILE} ) {
      $fh = _my_open( $this->{FILE} );
  } else {
      open $fh, '<', \$this->{STRING}
        or die "Failed to create file handle from in-memory string";
  }
  my $buf = '';

  my $parser = $this->{PARSER};
  $parser->YYData->{LEX}{FH} = $fh;
  $parser->YYData->{LEX}{BUFFER} = \$buf;

  $this->{DATA} = $parser->YYParse( yylex   => \&ExtUtils::XSpp::Grammar::yylex,
                                    yyerror => \&ExtUtils::XSpp::Grammar::yyerror,
                                    yydebug => 0x00,
                                   );
}

=head2 ExtUtils::XSpp::Parser::get_data

Returns a list containing the parsed data. Each item of the list is
a subclass of C<ExtUtils::XSpp::Node>

=cut

sub get_data {
  my $this = shift;
  die "'parse' must be called before calling 'get_data'"
    unless exists $this->{DATA};

  return $this->{DATA};
}

=head2 ExtUtils::XSpp::Parser::get_errors

Returns the parsing errors as an array.

=cut

sub get_errors {
  my $this = shift;

  return @{$this->{ERRORS}};
}

1;
