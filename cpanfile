requires 'perl', '5.14.1';

requires 'Plack::App::SeeAlso', '0.14';
requires 'Plack::Middleware::CrossOrigin';
requires 'Plack::Middleware::XForwardedFor';
requires 'PICA::Data', '0.25';

# not listed here because implied by required Debian packages:
# - Plack
# - YAML::XS
# - Image::Size
# - Business::ISBN
