use v5.14.1;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Plack::Util::Load;
use JSON::PP;
use File::Temp qw(tempdir);

$ENV{COVERDIENST_DATA} = tempdir( CLEANUP => 1 );

my $app = load_app( 'GBV::App::Coverdienst' );

test_psgi $app, sub {
    my ($cb, $res) = $_[0];

    # backwards compatibility
    $res = $cb->(GET '/');
    is $res->headers->{'content-type'}, 'application/xml', 'XML by default';
    
    $res = $cb->(GET '/?format=seealso');
    is $res->headers->{'content-type'}, 'application/json', '/?format=seealso';

    $res = $cb->(GET '/?format=seealso&id=123');
    is $res->headers->{'content-type'}, 'application/json', '/?format=seealso';

    $res = $cb->(GET '/?format=seealso&id=978-85-254-3295-7');
    is $res->headers->{'content-type'}, 'application/json', '/?format=seealso';

    is_deeply decode_json($res->content), 
        ["9788525432957", ["image/jpeg"], ["1561x2357"], ["?format=img&id=9788525432957"]],
        'SeeAlso response';

    $res = $cb->(GET '/?format=img&id=978-85-254-3295-7');
    is $res->headers->{'content-type'}, 'image/jpeg', '/?format=img';
};

done_testing;
