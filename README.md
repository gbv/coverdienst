# NAME

coverdienst - Cover images as SeeAlso service

[![Build Status](https://travis-ci.org/gbv/coverdienst.svg)](https://travis-ci.org/gbv/coverdienst)

# SYNOPSIS

The application is automatically started as service, listening on port 6027.

    sudo service coverdienst {status|start|stop|restart}

# DESCRIPTION

Coverdienst provides a SeeAlso web service for cover images.

* `format=img` liefert zu einer Anfrage-ID eine Bilddatei mit dem Cover oder, 
   falls kein Cover gefunden wurde, ein 1x1 Pixel großes transparentes GIF.

* `format=coverdienst` liefert Informationen über das Cover zu einer Anfrage-ID,
   bestehend aus MIMIE-Type (in der Regel `image/jpeg`), Bildgröße in Pixel
   und Anfrage-URL.

# INSTALLATION

The application is packaged as Debian package. No binaries are included, so the
package should work on all architectures. It is tested with Ubuntu 12.04 LTS.

Files are installed at the following locations:

* `/srv/coverdienst/` - application
* `/var/log/coverdienst/` - log files
* `/etc/default/coverdienst` - server configuration
* `/etc/coverdienst/` - application configuration

# CONFIGURATION

See `/etc/default/coverdienst` for basic configuration. Settings are not modified
by updates. Restart is needed after changes. The following keys are required:

* `PORT` - port number (required, 6009 by default)

* `WORKERS` - number of parallel connections (required, 5 by default). If put 
   behind a HTTP proxy, this number is not affected by slow cient connections 
   but only by the time of processing each request.

Additional configuration is placed in a YAML file in
`/etc/coverdienst/coverdienst.yaml`. The following keys are recognized, among
others:

* `proxy` - a space-or-comma-separated list of trusted IPs or IP-ranges
   (e.g. `192.168.0.0/16`) to take from the `X-Forwarded-For` header.
   The special value `*` can be used to trust all IPs.

Image files are located in `/srv/coverdienst/data/`. The directory
`/srv/coverdienst/bin` contains some maintainance scripts (can be called via
`carton exec -Ilib`). The script `isbn2file` can be used to map a given ISBN or
ISBN file to the corresponding cover image filename.

# SEE ALSO

Changelog is located in `debian/changelog` in the source code repository.

Source code and issue tracker at <https://github.com/gbv/coverdienst>. See
file `CONTRIBUTING.md` for details.

