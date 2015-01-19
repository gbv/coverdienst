package GBV::App::Covers;

use v5.14;
use parent 'Plack::App::SeeAlso';

use Plack::App::File;
use Plack::Request;
use Image::Size;
use Business::ISBN;
use File::Path qw(make_path);
use HTTP::Tiny;
use PICA::Data;
use JSON;

# constructur
sub new {
    my ($class, $config) = @_;

    # load all properties from config file
    unless (ref $config) {
        open my $fh, '<:encoding(UTF-8)', $config;
        local $/ = undef;
        $config = JSON->new->decode(<$fh>);
    }

    bless $config, $class;

    # predefined properties
    $config->{Formats} = {
        img => [ sub { $config->query_image(@_) } , $config->{mime} ]
    };

    $config->{empty_gif} = eval {
       use bytes; # transparent 1x1 gif
       my $data = "47 49 46 38 39 61 01 00 01 00 80 00 00 ff ff ff "
                . "00 00 00 21 f9 04 01 00 00 00 00 2c 00 00 00 00 "
                . "01 00 01 00 00 02 02 44 01 00 3b";
        pack '(H2)*',  map {substr($data,$_*3,2)} (0..42);
    };

    my $agent =  $config->{ShortName} . '/' . $config->{Version};
    $config->{http} = HTTP::Tiny->new( agent => $agent );

    $config;
}

# SeeAlso response (format=seealso)
sub query {
    my ($self, $id) = @_;

    if (my ($url, $size) = $self->lookup($id)) {
        if ($url !~ qr{^(https?:)?//}) {
            $url = $self->{base} . "?format=img&id=$id";
        }
        return [ $id, [$self->{mime}], [$size], [$url] ];
    } else {
        return [ $id, [], [], [] ];
    }
}

# image response (format=img)
sub query_image {
    my ($self, $env) = @_;

    my $req = Plack::Request->new($env);
    my $id  = $req->param('id');

    if (my ($file) = $self->lookup($id)) {
        return Plack::App::File->new(file => $file)->call($env);
    } else {
        return [200,['Content-Type'=>'image/gif'],[$self->{empty_gif}]];
    }
}

# look up image file and dimensions by query identifier
sub lookup {
    my ($self, $id) = @_;

    if ($id =~ /gvk:ppn:([0-9x]+)$/i) {
        return $self->lookup_via_gvkppn($1);
    } else {
        return $self->lookup_via_isbn($id);
    }
}

# look up image file and dimensions by isbn
sub lookup_via_isbn {
    my ($self, $isbn) = @_;
    my $file = $self->isbn2file(normalize_isbn($isbn));
    return $self->lookup_file($file);
    
    # TODO: search GVK via SRU for ISBN and check PPN covers
    # otherwise lookup via ISBN is not possible unless first lookup via PPN took place

}

# look up image file and dimensions by image file name
sub lookup_file {
    my ($self, $file) = @_;
    my ($sizex, $sizey) = imgsize($file);
    if ($sizex and $sizey) {
        return ($file,"${sizex}x${sizey}");
    } else {
        return;
    }
}

# maps ISBN to image file. Always constructs the file path.
sub isbn2file {
    my ($self, $isbn) = @_;
    return unless $isbn;

    my $path = join '/', $self->{cache}, 'isbn', map { substr($isbn,$_,3) } (0,3,6);
    make_path($path) unless -d $path;
    return "$path/$isbn.jpg";
}

# maps GVK PPN to image file. Always constructs the file path.
sub gvkppn2file {
    my ($self, $ppn) = @_;
    return unless $ppn;

    my $path = join '/', $self->{cache}, 'gvkppn', map { substr($ppn,$_,3) } (0,3);
    make_path($path) unless -d $path;
    return "$path/$ppn.jpg";
}

# normalize to ISBN13
sub normalize_isbn {
    my ($isbn) = @_;
    $isbn =~ s/^urn:isbn://i;
    $isbn = Business::ISBN->new($isbn) or return;
    return $isbn->as_isbn13->isbn;
}

# unique elements in a list
sub uniq {
    my %seen;
    return grep { !$seen{$_}++ } @_;
}

# Look up a cover by PPN
sub lookup_via_gvkppn {
    my $self = shift;
    my $ppn  = lc(shift);

    # get existing cover, indexed by PPN
    my $ppnfile = $self->gvkppn2file($ppn);
    if (-e $ppnfile) {
        return $self->lookup_file($ppnfile);
    }

    # get PICA+ record to look up cover link
    my $url = "http://unapi.gbv.de/?id=gvk:ppn:$ppn&format=pp";
    my $response = $self->{http}->get($url);
    return unless $response->{success};
    my $pica = PICA::Data::pica_parser('plain', \$response->{content});
    return unless $pica;

    # collect unique ISBNs in the record
    my @isbns = uniq( 
                    grep { $_ } map { normalize_isbn($_) }
                    map { $pica->values($_) } ('004A$A', '004A$0')
                );
    
    # collect cover links in the record
    $url = $pica->sf('009Q$a') || "";
    my $urltype = $pica->sf('009Q$3') || 0;
    if ( $url =~ /\.jpg/ and $urltype == 93 ) {
        $response = $self->{http}->mirror($url, $ppnfile);
        if ($response->{success}) {
            foreach my $isbn (@isbns) {
                my $isbnfile = $self->isbn2file($isbn);
                my $cache = $self->{cache};
                my $target = $ppnfile; 
                $target =~  s{$cache}{../../../..};
                symlink ($target, $isbnfile) unless -e $isbnfile;
            }
            return $self->lookup_file($ppnfile);
        }
    }

    # find covers by ISBNs in the record
    foreach my $isbn (@isbns) { 
        my $isbnfile = $self->isbn2file($isbn);
        if (-e $isbnfile) {
            my $target = $isbnfile;
            my $cache = $self->{cache};
            $target =~ s{$cache}{../../..};
            symlink $target, $ppnfile;
            return $self->lookup_file($isbnfile);
        }
    }

    return;
}

1;

=head1 LIMITATION

If PICA+ record has changed, one must delete all ISBN->PPN symlinks and PPN
file.

=cut
