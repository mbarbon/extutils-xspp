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
  local $parser->YYData->{PARSER} = $this;

  $this->{DATA} = $parser->YYParse( yylex   => \&ExtUtils::XSpp::Grammar::yylex,
                                    yyerror => \&ExtUtils::XSpp::Grammar::yyerror,
                                    yydebug => 0x00,
                                   );
  if (ref($this->{DATA})) {
    unshift @{$this->{DATA}},
      ExtUtils::XSpp::Node::Raw->new(rows =>['#include <exception>']);
  }
}

sub include_file {
  my $this = shift;
  my( $file ) = @_;
  my $buf = '';
  my $new_lex = { FH     => _my_open( $file ),
                  BUFFER => \$buf,
                  NEXT   => $this->{PARSER}->YYData->{LEX},
                  };

  $this->{PARSER}->YYData->{LEX} = $new_lex;
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

=head2 ExtUtils::XSpp::Parser::load_plugin

Loads the specified plugin and calls its C<register_plugin> method.

=cut

sub load_plugin {
  my $this = shift;
  my( $package ) = @_;

  if (eval "require ExtUtils::XSpp::Plugin::$package;") {
    $package = "ExtUtils::XSpp::Plugin::$package";
    $package->register_plugin( $this );
  }
  elsif (eval "require $package;") {
    $package->register_plugin( $this );
  }
  else {
    die "Could not load XS++ plugin '$package' (neither via the namespace "
       ."'ExtUtils::XS++::Plugin::$package' nor via '$package'). Reason: $@";
  }
  return 1;
}

=head2 ExtUtils::XSpp::Parser::add_post_process_plugin

Adds the specified plugin to be called after parsing is complete to
modify the parse tree before it is emitted.

=cut

sub add_post_process_plugin {
  my $this = shift;
  my( $plugin ) = @_;

  push @{$this->{PLUGINS}{POST_PROCESS}}, $plugin;
}

sub post_process_plugins { $_[0]->{PLUGINS}{POST_PROCESS} || [] }

1;
