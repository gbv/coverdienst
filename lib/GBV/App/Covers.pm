package GBV::App::Covers;

use v5.14;
use parent 'Plack::App::SeeAlso';

use Plack::App::File;
use Plack::Request;
use Image::Size;
use JSON;

sub new {
    my ($class, $config) = @_;

    # load all properties from config file
    open my $fh, '<:encoding(UTF-8)', $config;
    local $/ = undef;
    $config = JSON->new->decode(<$fh>);

    my $self = bless $config, $class;

    # predefined properties
    $config->{Formats} = {
        img => [ sub { $self->query_image(@_) } , 'image/jpeg' ]
    };

    $config->{empty_gif} = eval {
       use bytes; # transparent 1x1 gif
       my $data = "47 49 46 38 39 61 01 00 01 00 80 00 00 ff ff ff "
                . "00 00 00 21 f9 04 01 00 00 00 00 2c 00 00 00 00 "
                . "01 00 01 00 00 02 02 44 01 00 3b";
        pack '(H2)*',  map {substr($data,$_*3,2)} (0..42);
    };

    $self;
}

sub query {
    my ($self, $id) = @_;
    my ($file, $size) = $self->id2file($id);
    if ($file) {
        my $url = $self->{base} . "?format=img&id=$id";#?$file;
        return [ $id, ['image/jpeg'], [$size], [$url] ];
    } else {
        return [ $id, [] ];
    }
}

sub id2file {
    my ($self, $id) = @_;

    # TODO: normalize ISBN, lookup via PPN ...
    say STDERR "ID: $id";

    my $file = "data/isbn/978/184/195/9781841959535.jpg";

    my ($sizex, $sizey) = imgsize($file);
    if ($sizex and $sizey) {
        return ($file,"${sizex}x${sizey}");
    } else {
        return;
    }
}

sub query_image {
    my ($self, $env) = @_;

    my $req = Plack::Request->new($env);
    my $id  = $req->param('id');

    if (my ($file) = $self->id2file($id)) {
        # TODO: could return 403 (?)
        return Plack::App::File->new(file => $file)->call($env);
    }

    return [200,['Content-Type'=>'image/gif'],[$self->{empty_gif}]];
}

1;
