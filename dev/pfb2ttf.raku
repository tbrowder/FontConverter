#!/bin/env raku

use Proc::Easier;
use File::Find;

if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <font file to be converted, with correct suffix>

    Converts fonts in PostScript .pfb (or .pfa and .afm) to TTF or OTF formats
      using Python3 program 'ttf-converter':

      .pfb => .ttf or .otf

    Requires the following Linux system program: 

      fontforge
    HERE
    exit;
}

my $odir = "./out";
my $efil = "../resources/bin/ttf-converter".IO.absolute;
my @pfb;
my $to-otf = 0;
for @*ARGS {
    when /'.pfb' $/ {
        @pfb.push: $_;
    }
    when /'to-otf'/ {
        ++$to-otf;
    }
    default {
        note "Ignoring input arg '$_'";
    }
}

# execute with one or more files
my $output-dir = "--output-dir $odir";
my @ofils;
if not $to-otf {
    my $args = $output-dir ~ " " ~ @pfb.join(" ");
    my $exe  = "$efil $args";
    my $res  = cmd $exe;
    @ofils = find :dir($odir), :type<file>, :name(/'.ttf' $/);
}
else {
    # must do it the hard way for now: one exe per file
    for @pfb -> $fpath {
        my $fnam = $fpath.IO.basename;
        $fnam ~~ s/'.pfb' $/.otf/;
        my $args = "$output-dir $fpath $fnam";
        my $exe  = "$efil $args";
        my $res  = cmd $exe;
        my $ofil = "$odir/$fnam";
        next unless $ofil.IO.r;
        @ofils.push: $ofil;
    }
}

if not @ofils.elems {
    say "No output files found in dir '$odir'";
    exit;
}
say "See output files found in dir '$odir':";
say "  $_" for @ofils.sort;

=finish

    @ofils .= sort
for @pfb -> $fpath {
}

# join all args
my $args = @*ARGS.join(" ");
# pass to Proc::Easier
my $exe = "$efil $args";
my $res = cmd $exe;
say $res.out;
