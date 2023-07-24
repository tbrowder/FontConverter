#!/bin/env raku

use Proc::Easier;

if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <font file to be converted, with correct suffix>

    Converts fonts in PostScript .pfb (or .pfa and .afm) to TTF or OTF formats
      using Python3 program 'ttf-converter':

      .pfb          => .ttf or .otf

    Requires the following Linux system program: 

      fontforge
    HERE
    exit;
}

my $efil = "../resources/bin/ttf-converter".IO.absolute;
# join all args
my $args = @*ARGS.join(" ");
# pass to Proc::Easier
my $exe = "$efil $args";
my $res = cmd $exe;
say $res.out;
