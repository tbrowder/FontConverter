#!/bin/env raku

use Proc::Easier;
use File::Find;

if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <ttf or otf to converted, with correct suffix>
                          OR
                        clean

    Converts ttf and otf fonts to PostScript pfb
      using system program 'ttf2ufm':

      .ttf or .otf => .pfb, .t1a, .pfa, and .afm

    Requires the following Linux system programs: 

      + ttf2ufm   - to convert TrueType (.ttf) to PostScript Type 1
      + fontforge

    HERE
    exit;
}

my $ttf;
my $otf;
my $clean = 0;
for @*ARGS {
    when /'.ttf' $/ {
        $ttf = $_;
    }
    when /'.otf' $/ {
        $otf = $_;
    }
    when /:i c[lean]? $/ {
        ++$clean;
    }
    default {
        say "FATAL: Unknown file format: $_";
        exit;
    }
}

my $odir = mkdir "out";
my $exe = "ttf2ufm";
my ($args, $res, $bnam);
if $ttf.defined {
    $bnam = $ttf.IO.basename;
    $bnam ~~ s/'.ttf' $//;
    $args = "$ttf $odir/$bnam";
    $res  = cmd "$exe -b -G u $args";
    $res  = cmd "$exe -e -G u $args";
}
elsif $otf.defined {
    $bnam = $otf.IO.basename;
    $bnam ~~ s/'.otf' $//;
    $args = "$otf $odir/$bnam";
    $res  = cmd "$exe -b -G u $args";
    $res  = cmd "$exe -e -G u $args";
}
elsif $clean {
    my @rm;
    my @f = find :dir('.'), :type<file>, :recursive(False);
    for @f {
        when /'.' [afm||pfb||ufm||t1a||pfa] $/ {
            @rm.push: $_;
            unlink $_;
        }
    }
    if @rm.elems {
        note "Removed generated files:";
        note "  $_" for @rm.sort;
    }
}
