use v5.14.1;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;

use lib 't';
use AppLoader;
my $app = AppLoader->new( coverdienst => 'GBV::App::Covers' );

test_psgi $app, sub {
    my $cb = shift;
    my $res = $cb->(GET '/');
    is $res->code, '300', '/ => 300';
};

done_testing;
