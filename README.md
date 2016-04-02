# Fileman Web Project.

Licensed under Public Domain or Apache 2 if you can't use Public Domain.

This is an educational experiment in developing web interfaces to Vista File Manager. It is a fork of Dr. Sam Habiel's original fileman-web Github project (here: https://github.com/shabiel/fileman-web). This fork was created 2016-04-02 to collect my contributions to his project, to be added to the main branch of the repository when and if he sees fit.

At the time it was forked, the Mumps code in the repository is restricted to a single routine, DDWC001. At Dr. Habiel's request I'm going through his fileman-web code in routine DDWC001, studying it, and creating unit tests for it. The unit tests will be created using Dr. Habiel and Dr. Joel Ivey's M-unit unit-testing framework for Mumps (specifically, version 1.4, here: https://github.com/shabiel/M-Unit), and they will be collected in routines under the DDUW namespace, DDU as per the documentation for M-unit, collecting all unit tests for Fileman's DD namespace under a common DDU library, and DDUW to segment unit tests for the Fileman-web module together within that namespace.

Also at his request, I'll be looking for code in his m-web-server (here: https://github.com/shabiel/M-Web-Server) that ought to be moved into fileman-web, and I'll be creating unit tests for those moved subroutines as well.

I'll also be commenting the existing subroutines as I proceed, to capture my analysis of his subroutines and to help define which unit tests to write.

As time permits, I'll also expand the suite of Fileman calls fileman-web wraps up.

Since Dr. Habiel mentions every other day his disgust with all-uppercase Mumps, I'm also going to take this opportunity to convert most of fileman-web's language elements and local variables to lowercase, as the Vista Standards and Conventions permit.
