# NAME

coverdienst - Cover images as SeeAlso service

[![Build Status](https://travis-ci.org/gbv/coverdienst.svg)](https://travis-ci.org/gbv/coverdienst)

# SYNOPSIS

The application is automatically started as service, listening on port 6027.

    sudo service coverdienst {status|start|stop|restart}

# DESCRIPTION

Coverdienst provides a SeeAlso web service for cover images.

* `format=img` returns a cover image or a transparent 1x1 GIF given a document
   identifier

* `format=seealso` returns information about a cover image in Open Search 
   Suggestions / SeeAlso JSON format

       [ id, [ type ], [ size ], [ URL ] ]

   where `id` is the normalized given document identifier, `type` is
   `image/jpeg` or `image/gif`, `size` is the image size (e.g. `300x400`),
   and URL is the query URL with `format=img`.

SeeAlso JSON format can be queried by many means. A sample JavaScript client
is included and served at `/coverdienst.json`.

# INSTALLATION

The application is packaged as Debian package. No binaries are included, so the
package should work on all architectures. It is tested with Ubuntu 14.04 LTS.

Files are installed at the following locations:

* `/srv/coverdienst/` - application
* `/var/log/coverdienst/` - log files
* `/etc/default/coverdienst` - server configuration
* `/etc/coverdienst/` - application configuration

Cover images must manually be copied to `/srv/coverdienst/data/` and chown'ed
to user `coverdienst`.

# CONFIGURATION

See `/etc/default/coverdienst` for basic configuration. Settings are not modified
by updates. Restart is needed after changes. The following keys are required:

* `PORT` - port number (required, 6027 by default)

* `WORKERS` - number of parallel connections (required, 5 by default). If put 
   behind a HTTP proxy, this number is not affected by slow cient connections 
   but only by the time of processing each request.

Additional configuration is placed in the JSON file 
`/etc/coverdienst/coverdienst.json`. The following keys are recognized, among
others:

* `proxy` - a space-or-comma-separated list of trusted IPs or IP-ranges
   (e.g. `192.168.0.0/16`) to take from the `X-Forwarded-For` header.
   The special value `*` can be used to trust all IPs.

Image files are located in `/srv/coverdienst/data/`. The directory
`/srv/coverdienst/bin` contains some maintainance scripts.  The script
`isbn2file` can be used to map a given ISBN or ISBN file to the corresponding
cover image filename.

# SEE ALSO

Changelog is located in file [`debian/changelog`](debian/changelog) in the
source code repository.

Source code and issue tracker at <https://github.com/gbv/coverdienst>. See
file [`CONTRIBUTING.md`](CONTRIBUTING.md) for source code organization.

