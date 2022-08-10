deps:
	cpanm -l local --skip-satisfied --installdeps --notest .

run:
	plackup -r

test:
	prove -lv -Ilocal/lib/perl5
