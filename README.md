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

* `format=seealso` liefert Informationen über das Cover zu einer Anfrage-ID,
   bestehend aus MIMIE-Type (in der Regel `image/jpeg`), Bildgröße in Pixel
   und Anfrage-URL.

# INSTALLATION

The application is packaged as Debian package and installed at
`/srv/coverdienst/`. Log files are located at `/var/log/coverdienst/`.

# CONFIGURATION

See `/etc/default/wmbeacons` for basic configuration and
`/srv/coverdienst/covers.json` for additional settings. Restart is needed after
changes. 

Cover images are held in a special directory structure in

`/srv/coverdienst/data/`

`/srv/coverdienst/bin` contains some maintainance scripts (can be called via
`carton exec -Ilib`). The script `isbn2file` can be used to map a given ISBN or
ISBN file to the corresponding cover image filename.

# SEE ALSO

Source code at <https://github.com/gbv/coverdienst>

