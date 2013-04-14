#!/usr/bin/perl

use Test::More;
use FindBin qw/$Bin/;
use Data::Dumper qw(Dumper);
BEGIN { use_ok( "Assets::Fileinfo" ); }

my $assets = Assets::Fileinfo->new(directory => "$Bin/assets");
ok($assets->isa('Assets::Fileinfo'));

is($assets->directory, "$Bin/assets", 'directory set');

is(ref $assets->fileinfo, 'HASH', 'fileinfo set');
ok($assets->fileinfo->{'css/print.css'}{mtime} > 0, 'fileinfo mtime set');
is($assets->fileinfo->{'css/print.css'}{md5}, 'd1bd2440511227355570735e3392f798', 'fileinfo md5 match');

# print Dumper($assets->fileinfo), "\n";
done_testing();

