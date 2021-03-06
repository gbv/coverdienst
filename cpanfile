requires 'perl', '5.14.1';

requires 'Plack::App::SeeAlso', '0.14';
requires 'Plack::Middleware::CrossOrigin';
requires 'Plack::Middleware::XForwardedFor';
requires 'PICA::Data', '0.25';

test_requires 'Plack::Util::Load';

# not listed here because implied by required Debian packages:
# - Plack
# - JSON
# - Image::Size
# - Business::ISBN
