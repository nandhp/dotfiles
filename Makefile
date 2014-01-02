# Makefile - Wrapper for install.pl so that "make" does something obvious.
build:
%:
	@([ -d .git ] && which git >/dev/null 2>&1 && git submodule status | \
	  grep '^[^ ]' && echo 'Warning: submodules are out of date.' \
	  'Try git submodule update') || true
	@perl lib/install.pl --as-make $@
clean:
	rm -rf .build .install
