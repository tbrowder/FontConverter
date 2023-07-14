[![Actions Status](https://github.com/tbrowder/FontConverter/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/FontConverter/actions) [![Actions Status](https://github.com/tbrowder/FontConverter/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/FontConverter/actions) [![Actions Status](https://github.com/tbrowder/FontConverter/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/FontConverter/actions)

NAME
====

**FontConverter** - Enables conversion between TrueType and PostScript Type 1 fonts

SYNOPSIS
========

```raku
use FontConverter;
```

DESCRIPTION
===========

**FontConverter** is ...

    # for the docs =========
    Requires the following Linux system programs: 

    To convert TrueType to PostScript Type 1
      + ttf2ufm - converts X.ttf to X.t1a and X.afm

    To convert PostScript Type 1 to TrueType
      + fontforge - converts X.pfb to X.ttf

    Miscellaneous system programs:
      + pfbtopfa - .pfb to .pfa 
      + pdffonts - info on fonts in a pdf doc
      + pf2afm   - produces an afm file from a PostScript font
      + printafm - shows metrics from PostScript

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2023 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

