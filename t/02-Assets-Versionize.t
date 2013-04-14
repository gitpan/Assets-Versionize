#!/usr/bin/perl
use Test::More;
use FindBin qw/$Bin/;
BEGIN { use_ok( "Assets::Versionize" ); }

my $assets = Assets::Fileinfo->new(fileinfo => {
    'images/bg.gif' => {
        'md5' => '050cfc5650a32867e5f24982f906bb07'
    },
    'css/print.css' => {
        'md5' => 'd1bd2440511227355570735e3392f798'
    }
});
my $v = Assets::Versionize->new(assets => $assets);
my ($buf, $changed) = $v->processFileToString("$Bin/pages/a.html");
ok($changed, "changed");
is($buf, <<EOF, 'processFileToString');
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <link href="/css/print.vd1bd24.css">
  </head>

  <body>
    <img src="/images/bg.v050cfc.gif" />
    <link href="/css/print.vd1bd24.css"><img src="/images/bg.v050cfc.gif" />
    <img src="/images/fg.v000000.png" />
  </body>
</html>
EOF

done_testing();
