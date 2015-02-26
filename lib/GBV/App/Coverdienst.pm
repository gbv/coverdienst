package GBV::App::Coverdienst;
use v5.14;

our $VERSION="0.13";
our $NAME="coverdienst";

use GBV::App::Covers;
use Plack::Builder;
use Plack::Request;
use YAML::XS qw(LoadFile);
use parent 'Plack::Component';

# load config file
sub config {
    my ($self, $file) = @_;
    return unless -f $file;

    say $file;
    my $config = LoadFile($file);
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
    $self->config( grep { -f $_ } "etc/$NAME.yaml", "/etc/$NAME/$NAME.yaml" );

    # build middleware stack
    $self->{app} = builder {
        enable_if { $self->{PROXY} } 'XForwardedFor', trust => $self->{TRUST};
        enable 'CrossOrigin', origins => '*';
        enable 'JSONP';
        GBV::App::Covers->new($self)->to_app;
    };
}

sub call {
    my ($self, $env) = @_;
    $self->{app}->($env);
}

1;
