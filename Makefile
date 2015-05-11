
# extract build information from control file and changelog
POPEN  :=(
PCLOSE :=)
PACKAGE:=$(shell perl -ne 'print $$1 if /^Package:\s+(.+)/;' < debian/control)
VERSION:=$(shell perl -ne '/^.+\s+[$(POPEN)](.+)[$(PCLOSE)]/ and print $$1 and exit' < debian/changelog)
DEPENDS:=$(shell perl -ne 'print $$1 if /^Depends:\s+(.+)/;' < debian/control)
DEPLIST:=$(shell echo "$(DEPENDS)" | perl -pe 's/(\s|,|[$(POPEN)].+?[$(PCLOSE)])+/ /g')
ARCH   :=$(shell perl -ne 'print $$1 if /^Architecture:\s+(.+)/;' < debian/control)
RELEASE:=${PACKAGE}_${VERSION}_${ARCH}.deb
MAINSRC:=lib/GBV/App/Coverdienst.pm

info:
	@echo "Release: $(RELEASE)"
	@echo "Depends: $(DEPENDS)"

version:
	@perl -p -i -e 's/^our\s+\$$VERSION\s*=.*/our \$$VERSION="$(VERSION)";/' $(MAINSRC)
	@perl -p -i -e 's/^our\s+\$$NAME\s*=.*/our \$$NAME="$(PACKAGE)";/' $(MAINSRC)

# build documentation
PANDOC = $(shell which pandoc)
ifeq ($(PANDOC),)
  PANDOC = $(error pandoc is required but not installed)
endif

documentation: debian/$(PACKAGE).1
debian/$(PACKAGE).1: README.md debian/control
	@grep -v '^\[!' $< | $(PANDOC) -s -t man -o $@ \
		-M title="$(shell echo $(PACKAGE) | tr a-z A-Z)(1) Manual" -o $@

# build Debian package
release-file: documentation version
	prove -l -Ilocal/lib/perl5
	dpkg-buildpackage -b -us -uc -rfakeroot
	mv ../$(PACKAGE)_$(VERSION)_*.deb .
	git diff-index HEAD # FIXME?

# install required toolchain and Debian packages
dependencies:
	apt-get install fakeroot dpkg-dev
	apt-get install pandoc libghc-citeproc-hs-data 
	apt-get install $(DEPLIST)

local-lib:
	rm -rf local
	cpanm -l local --skip-satisfied --no-man-pages --notest --installdeps .
	rm -rf local/lib/perl5/x86_64-linux/

