# Contributing

See [`README.md`](README.md) for a general introduction.

* <http://github.com/gbv/coverdienst>: source code repository
* <http://github.com/gbv/coverdienst/issues>: issue tracker

Relevant source code is located in

* `lib/` - application sources (Perl modules)
* `debian/` - Debian package control files 
    * `changelog` - version number and changes 
      (use `dch` to update)
    * `control` - includes required Debian packages
    * `coverdienst.default` - default config file 
      (only installed with first installation)
    * `install` - lists which files to install
* `cpanfile` - lists required Perl modules
* `htdocs/` - static HTML/CSS/JS/... files

Additional files should not need to be modified unless there is a bug in the
Debian packaging or an upgrade requires some maintainance steps.

Most development tasks are automated in `Makefile`.

First make sure to install required Debian modules and `local/`:

    $ make dependencies
    $ make local-lib

During development you should locally run the service with automatic restart:

    $ plackup -r --port 6027
    
To run unit tests:

    $ prove -Ilocal/lib/perl5 -l

The environment variable `TEST_URL` affects which server the tests are run
against. This can also be used to test an installed service at another host.

Finally build a Debian package for release:

    $ make release-file

To cleanup:

    $ debuild clean

