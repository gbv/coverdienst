package GBV::App::Covers;
use v5.14;

use Plack::App::File;
use Plack::Request;
use Catmandu::SRU;
use Catmandu;
use PICA::Data qw(pica_subfields);
use File::Path qw(make_path);
use HTTP::Tiny;
use Business::ISBN;
use Image::Size;

use parent 'Plack::Component';

my $seealso = Plack::App::File->new( file => 'seealso.json' )->to_app;
my $empty   = Plack::App::File->new( file => 'img.gif' )->to_app;
my $xml     = Plack::App::File->new( file => 'covers.xml' )->to_app;

sub prepare_app {
    my $self = shift;

    $self->{data} = $ENV{COVERDIENST_DATA} || "./data";
    $self->{data} =~ s|/$||;

    $self->{client} = HTTP::Tiny->new;

    $self;
}

sub call {
    my ( $self, $env ) = @_;
    my $req = Plack::Request->new($env);

    my $format = $req->parameters->{format};

    # minmal backwards compatibility with unAPI/SeeAlso API
    return $xml->($env) if $format ne 'img' && $format ne 'seealso';

    my $id = Business::ISBN->new( $req->parameters->{id} );
    if ($id) {
        $id = $id->as_isbn13 if $id->type eq 'ISBN10';
        $id = $id->is_valid ? $id->as_string( [] ) : '';
    }

    if ($id) {
        my $path = join '/', $self->{data}, substr( $id, 3, 3 );
        my $file = "$path/$id.jpg";
        if ( !-f $file ) {
            if ( my $url = $self->query_image($id) ) {
                make_path $path
                  or die "Failed to create data directory '$path'\n";
                my $res = $self->{client}->mirror( $url, $file );
                if ( $res->{success} ) {
                    say STDERR "Download $url => $file";
                }
                else {
                    say STDERR "Failed to download $url";
                }
            }
            else {
                say STDERR "No Cover found for $id";
            }
        }

        if ( -f $file ) {
            if ( $format eq 'seealso' ) {
                my $url = "?format=img&id=$id";
                my ( $sizex, $sizey ) = imgsize($file);
                my $size = ( $sizex and $sizey ) ? "${sizex}x${sizey}" : "";
                my $body = "[\"$id\",[\"image/jpeg\"],[\"$size\"],[\"$url\"]]";
                return [ 200, [ "Content-Type", "application/json" ], [$body] ];
            }
            else {
                return Plack::App::File->new( file => $file )->to_app->($env);
            }
        }
    }

    return ( $format eq 'seealso' ? $seealso->($env) : $empty->($env) );
}

# map ISBN to Image URL (TODO: Cache zero-hit results)
sub query_image {
    my ( $self, $isbn ) = @_;

    my $records = Catmandu->importer(
        SRU          => base => 'http://sru.k10plus.de/opac-de-627',
        recordSchema => 'picaxml',
        parser       => 'picaxml',
        limit        => 10,
        total        => 10,
        query        => "pica.isb=$isbn"
    )->to_array;

    for (@$records) {
        for my $sf ( pica_subfields( $_, '017G' ) ) {

            # 017G{3 == 'Cover' && S != '0'}  # Cover, Weitgergabe gestattet
            if ( $sf->{3} eq 'Cover' && $sf->{S} ne '0' ) {

                # Ignore unless JPEG
                if ( $sf->{u} =~ /\.jpe?g$/ || $sf->{q} eq 'image/jpeg' ) {
                    return $sf->{u};
                }
            }
        }
    }
}

1;
