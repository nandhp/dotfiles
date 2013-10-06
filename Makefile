# Makefile - Wrapper for install.pl so that "make" does something obvious.
build:
%:
	@perl lib/install.pl --as-make $@
clean:
	rm -rf .build .install
