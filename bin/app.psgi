use v5.14.1;
use lib 'lib';
use GBV::App::Covers;
GBV::App::Covers->new("covers.json")->to_app;