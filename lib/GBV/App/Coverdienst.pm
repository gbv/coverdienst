package GBV::App::Coverdienst;
use v5.14;

use GBV::App::Covers;
use Plack::Builder;

use parent 'Plack::Component';

sub prepare_app {
    my ($self) = @_;
    return if $self->{app};

    open( $self->{log}, ">>", "./access.log" ) if -f "./access.log";

    # init core app
    my $covers = GBV::App::Covers->new(%$self);

    # build middleware stack
    $self->{app} = builder {
        enable_if { $self->{proxy} } 'XForwardedFor', trust => '*';
        enable_if { $self->{log} } 'AccessLog',
          logger => sub { print { $self->{log} } @_ };
        enable 'CrossOrigin', origins => '*';
        enable 'JSONP';
        $covers->to_app;
    };
}

sub call {
    my ( $self, $env ) = @_;
    $self->{app}->($env);
}

1;
