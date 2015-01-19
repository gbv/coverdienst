# GBV Coverdienst

Diese Anwendung stellt einen SeeAlso-Dienst bereit, um Coverbilder abzufragen.

* `format=img` liefert zu einer Anfrage-ID eine Bilddatei mit dem Cover oder, 
   falls kein Cover gefunden wurde, ein 1x1 Pixel großes transparentes GIF.

* `format=seealso` liefert Informationen über das Cover zu einer Anfrage-ID,
   bestehend aus MIMIE-Type (in der Regel `image/jpeg`), Bildgröße in Pixel
   und Anfrage-URL.

The application is packaged as Debian package and installed at 

  /srv/coverdienst/       - application files
  /var/log/coverdienst/   - log files
  /etc/init.d/coverdienst - init script

The application has been tested on Ubuntu >= 14.04.

[![Build Status](https://travis-ci.org/gbv/coverdienst.svg)](https://travis-ci.org/gbv/coverdienst)

See `.travis.yml` for internals.
