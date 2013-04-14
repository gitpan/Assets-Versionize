#!/usr/bin/perl

use warnings;
use strict;
use Pod::Usage;
use Getopt::Long;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Assets::Versionize;

my ($help, $dry_run, $verbose, $assets_dir, $prefix, $cache, $strict);
# default value for options
$prefix = '';
$cache = '.assets-fileinfo';
GetOptions(
    'help' => \$help,
    'dry-run' => \$dry_run,
    'no' => \$dry_run,
    'verbose' => \$verbose,
    'strict' => \$strict,
    'assets-dir=s' => \$assets_dir,
    'prefix=s' => \$prefix,
    'cache=s' => \$cache
);

if ( $help ) {
    pod2usage();
}
if ( !$assets_dir ) {
    print STDERR "Assets directory was not provided!\n\n";
    pod2usage(-1);
} elsif ( !-d $assets_dir ) {
    print STDERR "Assets directory '$assets_dir' is not exists!\n\n";
    pod2usage(-1);
}

my $processor = Assets::Versionize->new(
    assets => Assets::Fileinfo->new(
        directory => $assets_dir,
        cache_file => $cache,
    ),
    dry_run => $dry_run,
    verbose => $verbose,
    strict => $strict,
    prefix => $prefix,
);
$processor->process(@ARGV);

__END__

=head1 NAME

assets-versionize.pl - Utility to add version to js, css and image file name

=head1 VERSION

version 0.1

=head1 SYNOPSIS

assets-versionize.pl [--dry-run --quiet] --assets-dir assets-dir --prefix prefix file-or-dir

      -n/--dry-run    print the lines to add version, but do not execute replacement
      -q/--quiet      do not print the lines to add version
      -s/--strict     strict regexp to match file. The file should match \.v[0-9a-f]{6}\.
      -a/--assets-dir assets directory 
      -p/--prefix     the prefix of the js, css and images file name in code

=head1 DESCRIPTION

You can add following code to your nginx configuration：

    location ~ "\.v[0-9a-f]{6}\.(js|css|png|jpg|jpeg|gif|ico)$" {
        rewrite "^(.*)\.v[0-9a-f]{6}\.(js|css|png|jpg|jpeg|gif|ico)$" $1.$2 last;
    }

    location ~ \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires max;
        log_not_found off;
    }

=head1 AUTHOR

Ye Wenbin, E<lt>wenbinye@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Ye Wenbin

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
