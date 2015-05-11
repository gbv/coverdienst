use v5.14.1;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Plack::Util::Load;

my $app = load_app( $ENV{TEST_URL} || 'GBV::App::Coverdienst' );

test_psgi $app, sub {
    my $cb = shift;
    my $res = $cb->(GET '/');
    is $res->code, '300', '/ => 300';

    $res = $cb->(GET '/coverdienst.js');
    is $res->code, '200', 'coverdienst.js';
};

done_testing;
