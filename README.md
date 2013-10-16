dotfiles
========

Usage
-----

    make                # Compile dotfiles
    make diff           # Diff new dotfiles against the existing ones
    make noact          # Show the commands make install will perform
    make install        # Install the dotfiles from the repository

Background and Motiviation
--------------------------

I've been wanting to put my dotfiles in git for awhile now, but
there's been two issues holding me back: I don't always want my
dotfiles to be the same everywhere, and I'd like them to be a bit more
organized.

For example, there are several options I would like to enable in my
`~/.nanorc`. However, they were introduced in nano 2.1, which is not
available everywhere, and nano complains when it encounters an option
it doesn't recognize. So I need my `nanorc` to adapt to the available
version of nano.

I'd also like to organize my dotfiles better. For example, rather than
having all of my environment variables in `bash_profile`, I would like
to organize them into multiple files (`perl/perl5lib.bash_profile`,
`private/secret-env.bash_profile`, and so on). This approach allows me
to easily add or remove features from my configuration. To do this, I
need to be able to assemble my dotfiles out of components, somewhat
like `run-parts`.

So I wrote a preprocessor (I'm currently calling it QUPP, for no very
good reason) that allows inline Perl code in arbitrary files. It's a
similar concept to PHP, but it uses Perl instead of... something else.
This satisfies both of my requirements, and more.

Combined with a little script to compile and install the dotfiles, I
think I have a reasonably powerful system personalization utility. If
you're interested, the code that powers it is in the `lib/` directory.

License
-------

See individual files; this distribution includes files covered by
multiple licenses.
