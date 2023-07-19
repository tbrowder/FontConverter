[![Actions Status](https://github.com/tbrowder/FontConverter/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/FontConverter/actions) [![Actions Status](https://github.com/tbrowder/FontConverter/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/FontConverter/actions) [![Actions Status](https://github.com/tbrowder/FontConverter/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/FontConverter/actions)

NAME
====

**FontConverter** - Enables conversion between TrueType, OpenType, and PostScript Type 1 fonts

SYNOPSIS
========

```raku
use FontConverter;
fc-convert-font Times-Roman.pfb # OUTPUT: «Times-Roman.ttf␤»
```

DESCRIPTION
===========

**FontConverter** provides tools to convert PostScript Type 1 binary font files to TrueType as well as conversion from TrueType or OpenType to PostScript Type 1. It requires the following system programs to be installed:

  * fontforge (and its Python3 components, if any)

    To convert PostScript Type 1 to TrueType (X.pfb to X.ttf).

Note the conversion from PostScript to True- or OpenType requires a Python3 script because `fontforge`'s own scripting language is broken (see its issue #5261 at [https://github.com/fontforge/fontforge](https://github.com/fontforge/fontforge)). We are fortunate to have found and been able to incorporate such a ready-made program at [https://antlarr-suse](https://antlarr-suse), and we are indebted to its author, Antonio Larrosa (who also happens to be a contributor to the **SUSE** Linux distribution).

  * ttf2ufm

    To convert TrueType or OpenType to PostScript Type 1 (X.ttf or X.otf to X.pfb, X.pfa, and X.afm).

Other font-related system programs:

  * pfbtopfa - converts .pfb to .pfa 

  * pdffonts - information on fonts in a PDF document

  * pf2afm - produces an AFM file from a PostScript font

  * printafm - shows metrics from a PostScript font

  * showttf - provides details of a TrueType or OpenType font

Motivation
==========

The author has been creating Raku modules to convert his old (but cool) PostScript-generating programs (whose products were then converted to PDF with Ghostscript's 'ps2pdf') to direct PDF-generation using David Warring's Raku PDF modules. In the process, he wanted to convert old PostScript Type 1 fonts he bought for special projects to TrueType. Hence this module, which brings together the necessary tools into an easy-to-use, double-duty module and encourages use of Unicode in multi-language printed products.

For completeness, the module also provides the opposite conversion for the rare case of wanting a PostScript version of a modern font for direct inclusion into a PostScript product.

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

    # Copyright (C) 20202 [sic] <Antonio Larrosa <alarrosa@suse.com>
    # This file is part of ttf-converter
    # <https://github.com/antlarr-suse/ttf-converter>.
    #
    # ttf-converter is free software: you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation, either version 3 of the License.

