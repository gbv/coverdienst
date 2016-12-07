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

    ok $res->content !~ qr{xml-stylesheet}m, 'no stylesheet';

    $res = $cb->(GET '/coverdienst.js');
    is $res->code, '200', 'coverdienst.js';

    my $ppn=601820754; 
    my $res = $cb->(GET "/?id=gvk:ppn:$ppn&format=seealso");
    is $res->code, '200', "gvk:ppn:$ppn";
    like $res->content, qr{\["gvk:ppn:601820754",\["image/jpeg"\]};
};

done_testing;
