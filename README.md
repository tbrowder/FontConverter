[![Actions Status](https://github.com/tbrowder/FontConverter/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/FontConverter/actions) [![Actions Status](https://github.com/tbrowder/FontConverter/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/FontConverter/actions) [![Actions Status](https://github.com/tbrowder/FontConverter/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/FontConverter/actions)

NAME
====

**FontConverter** - Enables conversion between TrueType, OpenType, and PostScript Type 1 fonts

SYNOPSIS
========

```raku
use FontConverter;
fc-convert-font Times-Roman.pfb # OUTPUT: Times-Roman.ttf
```

DESCRIPTION
===========

**FontConverter** provides tools to convert PostScript Type 1 binary font files to TrueType as well as conversion from TrueType or OpenType to PostScript Type 1. It requires the following system programs to be installed:

  * fontforge (and its Python components)

    To convert PostScript Type 1 to TrueType (X.pfb to X.ttf).

  * ttf2ufm

    To convert TrueType or OpenType to PostScript Type 1 (X.ttf or X.otf to X.pfb, X.pfa, and X.afm).

Other font-related system programs:

  * pfbtopfa - converts .pfb to .pfa 

  * pdffonts - info on fonts in a pdf doc

  * pf2afm - produces an afm file from a PostScript font

  * printafm - shows metrics from PostScript

  * showttf - provides details of a TrueType or OpenType font

Motivation
==========

The author has been creating Raku modules to convert old PostScript-generating programs (whose products were then converted to PDF) to direct PDF-generation. In the process, he wants to convert old PostScript Type 1 fonts he bought for special projects to TrueType.

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2023 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

ADDITIONAL LICENSE
==================

The included Python3 program, `ttf-converter`, has its own license which is embedded in its contents at the top of the file. The first few lines are repeated here:

    # Copyright (C) 20202 Antonio Larrosa <alarrosa@suse.com>
    # This file is part of ttf-converter
    # <https://github.com/antlarr-suse/ttf-converter>.
    #
    # ttf-converter is free software: you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation, either version 3 of the License.

