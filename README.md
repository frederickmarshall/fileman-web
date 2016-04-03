# Fileman Web Project.

Licensed under Public Domain or Apache 2 if you can't use Public Domain.

This is an educational experiment in developing web interfaces to Vista File Manager. It is a fork of Dr. Sam Habiel's original fileman-web Github project (here: https://github.com/shabiel/fileman-web). This fork was created 2016-04-02 to collect my contributions to his project, to be added to the main branch of the repository when and if he sees fit.

=====

to do:

At the time it was forked, the Mumps code in the repository is restricted to a single routine, DDWC001. At Dr. Habiel's request I'm going through his fileman-web code in routine DDWC001, studying it, and creating unit tests for it. The unit tests will be created using Dr. Habiel and Dr. Joel Ivey's M-unit unit-testing framework for Mumps (specifically, version 1.4, here: https://github.com/shabiel/M-Unit), and they will be collected in routines under the DDUW namespace, DDU as per the documentation for M-unit, collecting all unit tests for Fileman's DD namespace under a common DDU library, and DDUW to segment unit tests for the Fileman-web module together within that namespace.

Also at his request, I'll be looking for code in his m-web-server (here: https://github.com/shabiel/M-Web-Server) that ought to be moved into fileman-web, and I'll be creating unit tests for those moved subroutines as well.

I'll also be commenting the existing subroutines as I proceed, to capture my analysis of his subroutines and to help define which unit tests to write.

As time permits, I'll also expand the suite of Fileman calls fileman-web wraps up.

Since Dr. Habiel mentions every other day his disgust with all-uppercase Mumps, I'm also going to take this opportunity to convert most of fileman-web's language elements and local variables to lowercase, as the Vista Standards and Conventions permit.

I need to fill out file WEB SERVICE URL HANDLER (17.6001) with the records described below.

I also want to create file BACH WERKE VERZEICHNIS (1001) so my experiments with fileman-web can work the same examples Dr. Habiel uses, to ensure I'm getting similar results. I plan to use this file in the unit tests I write.

=====

This software module consists of:

Routines

-  a. DDWC001 [commit on 2013-12-18]

Documentation files

-  a. INSTALL.md [commit on 2013-12-18]

-  b. README.md [commit on 2013-12-18]

-  c. doc_how_to.txt [commit on 2014-02-05]

Cascading style sheets

-  a. app.css [commit on 2013-12-18]

-  b. foundation.min.css [commit on 2013-12-18]

-  c. normalize.css [commit on 2013-12-18]

Hypertext files

-  a. fileman-demo.html [commits on 2013-12-18,25]

-  b. typeahead.html [commit on 2013-12-25]

Javascript files

-  a. DDWC.js [commits on 2013-12-18,25]

-  b. DDWC-test-mocha.js [commits on 2013-12-19,20,25]

Global-output files

-  a. DDWC001.zwr [commit on 2013-12-18]

Records in file WEB SERVICE URL HANDLER (17.6001), a Fileman-compatible global data structure stored in ^%W(17.6001) and created as part of the Mumps Advanced Shell to support m-web-server. These records expose Vista web services. They come in several groups.

First are the Fileman-related services created as part of fileman-web:

-  a. GET fileman/dd/{fields} calls DD^DDWC001 [commit on 2013-12-18, described in DDWC001.zwr]

-  b. POST fileman/vals calls VALS^DDWC001 [commit on 2013-12-18, described in DDWC001.zwr]

-  c. POST fileman/fda calls FDAPOST^DDWC001 [commit on 2014-02-05, described in doc_how_to.txt]

Second are the Fileman-related services created as part of m-web-server, which are candidates for moving to fileman-web:

-  d. GET fileman/{file}/{iens} calls F^%W0

-  e. GET fileman/{file}/{iens}/{field} calls FV^%W0

Third are Vista-pharmacy-related services created as part of m-web-server in support of the Mocha pharmacy project:

-  f. GET mocha/{type} calls MOCHA^%W0

-  g. POST mocha/{type} calls MOCHAP^%W0

-  h. POST MOCHA/ordercheck calls MOCHAP^%W0

Fourth and finally are low-level Mumps services created as part of m-web-server or Vista's Virtual Patient Record (vpr, later rebundled into the Health Management Platform, hmp or ehmp); these truly belong permanently within m-web-server:

-  i. OPTIONS rpc/{rpc} calls RPCO^%W0

-  j. POST rpc/{rpc} calls RPC^%W0

-  k. GET xml calls XML^VPRJRSP

-  l. POST xmlpost calls POSTTEST^%W0

-  m. GET r/{routine?.1"%25".32AN} calls R^%W0

-  n. PUT r/{routine?.1"%25".32AN} calls PR^%W0

-  o. GET filesystem/* calls FILESYS^%W0

Although the INSTALL.md files says to just load the global data in the zwr file, disregard this. Instead, read doc_how_to.txt and DDWC001.zwr and use them as guides to manually enter however many of these fifteen services you find missing from the file. If you are not yet familiar with the use of Fileman to enter and edit records, you must first learn and practice using Fileman to be sure you get this step right (for Fileman's manuals, read here: http://www.va.gov/vdl/application.asp?appid=5). When fileman-web eventually metamorphoses from a development and educational project into production software, this record-installation process will be streamlined to remove the need for such expertise during installs.
