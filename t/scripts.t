use v5.14.1;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;

my $file = qx{bin/isbn2file 9782330004576};
is $file, "data/isbn/978/233/000/9782330004576.jpg\n", 'isbn2file';

my $sizes = qx{bin/sizes};
note $sizes;

done_testing;
