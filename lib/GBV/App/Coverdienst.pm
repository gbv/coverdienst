package GBV::App::Coverdienst;
use v5.14;

our $VERSION="0.14";
our $NAME="coverdienst";

use GBV::App::Covers;
use Plack::Builder;
use Plack::Request;
use JSON;
use parent 'Plack::Component';

# load config file
sub config {
    my ($self, $file) = @_;
    return unless -f $file;

    my $config = decode_json( do { local (@ARGV, $/) = $file; <> } );

    while (my ($key, $value) = each %$config) {
        $self->{$key} = $value;
        if ($key eq 'proxy' and $value !~ /^[*]\s*$/) {
            $self->{trust} = [ split /\s*,\s*|\s+/, $self->{proxy} ];
        }
    }
}

sub prepare_app {
    my ($self) = @_;
    return if $self->{app};

    # load config file
    $self->config( grep { -f $_ } "etc/$NAME.json", "/etc/$NAME/$NAME.json" );

    # init Core app
    $self->{_covers} = GBV::App::Covers->new($self);

    # build middleware stack
    $self->{app} = builder {
        enable_if { $self->{PROXY} } 'XForwardedFor', 
            trust => $self->{TRUST};
        enable 'Static', 
            path => qr{\.(html|js|css)$},
            root => 'htdocs/',
            pass_through => 1;
        enable 'CrossOrigin', origins => '*';
        enable 'JSONP';        
        $self->covers->to_app;
    };
}

sub covers {
    $_[0]->{_covers};
}

sub call {
    my ($self, $env) = @_;
    $self->{app}->($env);
}

1;
