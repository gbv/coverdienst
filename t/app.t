use v5.14;
use Test::More;
use GBV::App::Covers;

my $app = GBV::App::Covers->new({});
isa_ok($app, 'GBV::App::Covers');

done_testing;
