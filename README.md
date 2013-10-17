dotfiles
========

Usage
-----

    make                # Compile dotfiles
    make diff           # Diff new dotfiles against the existing ones
    make noact          # Show the commands make install will perform
    make install        # Install the dotfiles from the repository

Motivation and Features
-----------------------

I wanted to put my dotfiles in git for awhile, but I couldn't find a
dotfile manager that supported all of the features I wanted. By
implementing inline Perl scripting, I enable these features:

* **Environment-aware.** Sometimes configuration files have to take
    the local environment into account. For example, there are several
    options I would like to enable in my `.nanorc`. However, they were
    introduced in nano 2.1, which is not available everywhere, and
    nano complains when it encounters an option it doesn't recognize.
    So I need my `nanorc` to automatically adapt to the available
    version of nano.

* **Organizable.** Some configuration files (`.bashrc`, `.emacs`) can
    get very long and complicated. I would like a way to organize the
    contents of my dotfiles. For example, rather than having all of my
    environment variables in `bash_profile`, I would like to split
    them into multiple files by topic: `perl/perl5lib.bash_profile`,
    `private/secret-env.bash_profile`, and so on. This allows me to
    easily add or remove features from my configuration. This means I
    need to be able to assemble my dotfiles out of components,
    somewhat like `run-parts`.

* **Cooperative.** Sometimes I want to part of a dotfile in git and
    the rest of it configured independently. For example, my
    `.xscreensaver` file has a painstakingly configured list of
    screenhacks, which I would like to use everywhere. However, other
    settings, like timeouts and power management, I want to adjust
    using `xscreensaver-demo`. The inline scripting capability allows
    the new version of the configuration file to composed based on the
    installed version.

* **Universal.** Many dotfile managers are written in Ruby or Python.
    Some of my computers don't have Ruby, and some are still running
    Python 2.4. But you can always rely on a modern version of Perl.

So I wrote a preprocessor (I'm currently calling it QUPP, for no very
good reason) that allows inline Perl code in arbitrary files. It's a
similar concept to PHP, but it uses Perl instead of something else.
This capability enables all of the above features and more. Combined
with a little script to compile, diff, and install new versions of the
dotfiles, I think I have developed a reasonably powerful system
personalization utility. All of this code can be found in the `lib/`
subdirectory.

License
-------

See individual files; this repository includes files covered by a
variety of licenses.
