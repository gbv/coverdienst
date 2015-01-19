use v5.14.1;
use Test::More;
use HTTP::Tiny;

# only test on ci server
plan skip_all => 1 unless $ENV{CI};

# read default configuration
my $config = "/etc/default/coverdienst";
my %conf = do { 
    local(@ARGV) = $config; 
    map { /^\s*([^=\s#]+)\s*=\s*([^#\n]*)/ ? ($1 => $2) : () } <>;
};
note $config, ": ", explain \%conf;

# run test
my $url = "http://localhost:$conf{PORT}";
my $res = HTTP::Tiny->new->get($url);
note explain $res;
is $res->{status}, 300, "$url => 300";

done_testing;
