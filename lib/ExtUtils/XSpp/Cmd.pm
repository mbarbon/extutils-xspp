package ExtUtils::XSpp::Cmd;

use strict;

=head1 NAME

ExtUtils::XSpp::Cmd - implementation of xspp

=head1 SYNOPSIS

  perl -MExtUtils::XSpp::Cmd -e xspp -- <xspp options and arguments>

In Foo.xs

  INCLUDE: perl -MExtUtils::XSpp::Cmd -e xspp -- <xspp options and arguments>

Using C<ExtUtils::XSpp::Cmd> is equivalent to using the C<xspp>
command line script, except that there is no guarantee for C<xspp> to
be installed in the system PATH.

=head1 DOCUMENTATION

See L<ExtUtils::XSpp>, L<xspp>.

=cut

use Exporter 'import';
use Getopt::Long;

use ExtUtils::XSpp::Driver;

our @EXPORT = qw(xspp);

sub xspp {
    my @typemap_files;
    GetOptions( 'typemap=s' => \@typemap_files );

    my $driver = ExtUtils::XSpp::Driver->new
      ( typemaps   => \@typemap_files,
        file       => shift @ARGV,
        );
    my $success = $driver->process;

    return $success ? 0 : 1;
}

1;
