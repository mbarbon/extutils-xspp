package ExtUtils::XSpp::Cmd;

use strict;

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
