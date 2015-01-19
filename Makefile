debian/coverdienst.1: README.md
	grep -v '^\[!' $< | pandoc -s -t man -M title="COVERDIENST(1) Manual" -o $@

local:
	carton install

debian-clean:
	fakeroot debian/rules clean

depencencies:
	carton install

debian-package:
	dpkg-buildpackage -b -us -uc -rfakeroot
	mv ../coverdienst_* .
