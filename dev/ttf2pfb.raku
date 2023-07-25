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

    Converted fonts are placed in the './out' directory. Use
    the 'clean' mode to delete all files there.

    Requires the following Linux system programs: 

      + ttf2ufm   - to convert TrueType (.ttf) to PostScript Type 1
      + fontforge

    HERE
    exit;
}

my @ttf;
my @otf;
my $clean = 0;
for @*ARGS {
    when /'.ttf' $/ {
        @ttf.push: $_;
    }
    when /'.otf' $/ {
        @otf.push: $_;
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
for @ttf -> $ttf {
    $bnam = $ttf.IO.basename;
    $bnam ~~ s/'.ttf' $//;
    $args = "$ttf $odir/$bnam";
    $res  = cmd "$exe -b -G u $args";
    $res  = cmd "$exe -e -G u $args";
    my $pfa = "$odir/$bnam.pfa";
    my $tia = "$odir/$bnam.t1a";
    copy $pfa, $tia; # copy $path-from, $path-to
}
for @otf -> $otf {
    $bnam = $otf.IO.basename;
    $bnam ~~ s/'.otf' $//;
    $args = "$otf $odir/$bnam";
    $res  = cmd "$exe -b -G u $args";
    $res  = cmd "$exe -e -G u $args";
    my $pfa = "$odir/$bnam.pfa";
    my $tia = "$odir/$bnam.t1a";
    copy $pfa, $tia; # copy $path-from, $path-to
}
if $clean {
    my @rm;
    my @f = find :dir<out>, :type<file>, :recursive(False);
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
    exit;
}

# report files in ./out
my @of = find :dir<./out>, :type<file>;
say "Generated files in dir './out':";
say "  $_" for @of.sort;

