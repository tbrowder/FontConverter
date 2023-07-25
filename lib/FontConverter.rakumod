use Proc::Easier;
use File::Find;
use File::Temp;

unit class FontConverter is export;

submethod TWEAK {
}

# If more than one font arg is entered, 
# they are all checked. Those with suffixes 
# of .ttf or .otf are sent to 'ttf-converter'
# and those with .pfa are to 'ttf2ufm'.
method run-program(@args) {
    my $show   = 0; # an undocumented debug option
    my $debug  = 0;
    my %pfb;
    my %ttf;
    my %otf;
    my %other;

    # handle input and output directories
    my $cdir = $*CWD.IO.absolute; # default
    my $idir;                     # no default
    my $odir = $cdir;             # default, but will throw unless the user picks another
                                  # that is NOT the $idir or the $cdir

    # collect any fonts in args
    for @args {
        my $bnam;
        when /'in-dir=' (\S+) $/ {
            $idir = ~$0.IO.absolute;
            die "FATAL: Input arg in-dir='$idir' is NOT a directory." unless $idir.IO.d;
        }
        when /'out-dir=' (\S+) $/ {
            $odir = ~$0.IO.absolute;
            die "FATAL: Input arg out-dir='$odir' is NOT a directory." unless $odir.IO.d;
            die "FATAL: Input arg out-dir='$odir' can NOT be the CWD" unless $odir ne $cdir;
        }
        when /'.pfb' $/ {
            $bnam = $_.IO.basename;
            %pfb{$bnam} = $_;
        }
        when /'.ttf' $/ {
            $bnam = $_.IO.basename;
            %ttf{$bnam} = $_;
        }
        when /'.otf' $/ {
            $bnam = $_.IO.basename;
            %otf{$bnam} = $_;
        }
        when /:i debug $/ {
            ++$debug;
        }
        when /:i show $/ {
            ++$show;
        }
        default {
            %other{$_} = 1;
        }
    }

    if $show {
        # for debugging
        my $cdir = $*CWD;
        if not $cdir.contains('dev') {
            note "FATAL: Dir '$cdir' is not the 'dev' dir";
            note "Debug exit";
            exit;
        }
        my $dir1 = "$cdir/../t/fonts";
        my $dir2 = "$cdir/../t/fonts/idir";
        my $dir3 = "$cdir/../t/out";
        my @f1 = find :dir($dir1), :type<file>, :recursive(False);
        my @f2 = find :dir($dir2), :type<file>, :recursive(False);
        my @f3 = find :dir($dir3), :type<file>, :recursive(False);
        note "Files in $dir1:";
        note "  $_" for @f1.sort;
        note "Files in $dir2:";
        note "  $_" for @f2.sort;
        note "Files in $dir3:";
        note "  $_" for @f3.sort;
        note "Debug exit";
        exit;
    }
 
    # idir and odir must NOT be the same
    if $idir.defined {
        die "FATAL: Input arg in-dir='$idir' is NOT a directory." unless $idir.IO.d;
        die "FATAL: Input in-dir='$idir' and out-dir can NOT be the same" unless $idir ne $odir;

        # collect files from the input directory
        my @fils = find :dir($idir), :type<file>, :recursive(False), :name(/'.' [pfb||otf||ttf] $/);
        # add them to the appropriate hash
        for @fils {
            my $bnam;
            when /'.pfb' $/ {
                $bnam = $_.IO.basename;
                %pfb{$bnam} = $_;
            }
            when /'.ttf' $/ {
                $bnam = $_.IO.basename;
                %ttf{$bnam} = $_;
            }
            when /'.otf' $/ {
                $bnam = $_.IO.basename;
                %otf{$bnam} = $_;
            }
        }
    }

    # Check input font files results
    if not (%pfb.elems or %ttf.elems or %otf.elems) {
        say "ERROR: No .pfb, .ttf, or .otf files found via the input args.";
        say "       Exiting.";
        exit;
    }

    # Finally, do the conversions
    my (@ttf, @pfb, @otf);
    if %pfb.elems {
        # handle the conversion
        @ttf = convert-pfb2ttf %pfb.values, :$odir, :$debug;
    }
    if %ttf.elems {
        # handle the conversion
        my @f = convert-ttf2pfb %ttf.values, :$odir, :$debug;
        @pfb.push: |@f;
    }
    if %otf.elems {
        # handle the conversion
        my @f = convert-ttf2pfb %otf.values, :$odir, :$debug;
        @pfb.push: |@f;
    }

    my @ofils;
    if @pfb {
        @ofils.push: |@pfb;
    }
    if @ttf {
        @ofils.push: |@ttf;
    }
    if @otf {
        @ofils.push: |@otf;
    }
    @ofils .= sort;
}

sub convert-pfb2ttf(@fonts, :$odir!, :$debug --> List) is export(:test) {
    note "NOTE: this dir is: '{$odir.IO.absolute}'" if $debug;
    # use ttf-convert (a Python program)
    # to create a .ttf file from a .pfb file
    my $eloc1 = %?RESOURCES<bin/ttf-converter>.IO // 0;
    my $eloc2 = "resources/bin/ttf-converter".IO // 0;
    my $efil  = $eloc1 ?? $eloc1 
                       !! $eloc2.IO.r ?? $eloc2 
                                      !! die("FATAL: Unable to open 'ttf-converter'");
    note "DEBUG: Using pfb conversion program '$efil'" if $debug;
    # execute with one or more files
    my $output-dir = "--output-dir $odir";
    my @ofils;
    if 1 { #not $to-otf {
        my $args = $output-dir ~ " " ~ @fonts.join(" ");
        my $exe  = "$efil $args";
        my $res  = cmd $exe;
        @ofils = find :dir($odir), :type<file>, :name(/'.ttf' $/);
    }
    else {
        die "FATAL: Unable to convert .otf to .pfb";
        # must do it the hard way for now: one exe per file
        for @fonts -> $fpath {
            my $fnam = $fpath.IO.basename;
            $fnam ~~ s/'.pfb' $/.otf/;
            my $args = "$output-dir $fpath $fnam";
            my $exe  = "$efil $args";
            my $res  = cmd $exe;
            my $ofil = "$odir/$fnam";
            @ofils.push: $ofil;
        }

    }
    @ofils .= sort
}

sub convert-ttf2pfb(@fonts, :$odir!, :$debug --> List) is export(:test)  {
    note "NOTE: this dir is: '{$odir.IO.absolute}'" if $debug;
    # use ttf2ufm to create .pfb, .pfm, .t1a, and .afm files 
    # from a .ttf or .otf file
    my $eprog = "ttf2ufm";
    note "DEBUG: Using ttf/otf pfb conversion program '$eprog'" if $debug;
    # each file has to be handled separately with two executions

    # the only way to output a file into another directory is to
    # specify it in the output file name (.i.e., use the complete path).

    # until happy with output, use another dir
    my $tdir = "$odir/out2";
    mkdir $tdir;

=begin comment
    $bnam = $ttf.IO.basename;
    $bnam ~~ s/'.ttf' $//;
    $args = "$ttf $odir/$bnam";
    $res  = cmd "$exe -b -G u $args";
    $res  = cmd "$exe -e -G u $args";
    my $pfa = "out/$bnam.pfa";
    my $tia = "out/$bnam.t1a";
    copy $pfa, $tia;
=end comment

    for @fonts -> $font {
        my $bnam = $font.IO.basename;
        $bnam ~~ s/'.' [t|o] tf $//;

        my $args = "$font $tdir/$bnam";
        my $res1 = cmd "$eprog -b -G u $args";
        my $res2 = cmd "$eprog -e -G u $args";
        my $pfa  = "$tdir/$bnam.pfa";
        my $tia  = "$tdir/$bnam.t1a";
        copy $pfa, $tia;
    }

    # copy to outdir

    # collect the tdir paths
    my @tf  = find :dir($tdir), :type<file>, :recursive(False);
    my %tf;
    for @tf -> $fpath {
        my $bnam = $fpath.IO.basename;
        %tf{$bnam} = $fpath;
    }

    # collect the odir paths
    my @of = find :dir($odir), :type<file>, :recursive(False);
    my %of;
    for @of -> $fpath {
        my $bnam = $fpath.IO.basename;
        %of{$bnam} = $fpath;
    }

    # merge into $odir
    my @olist;
    for %tf.kv -> $fbnam, $fpath {
        if %of{$fbnam}:exists {
            note "NOTE: generated file '$fbnam' also found in dir '$odir'";
            @olist.push: %of{$fbnam}.IO;
        }
        else {
            copy %tf{$fbnam}, "$odir/$fbnam";
            unlink %tf{$fbnam};
            @olist.push: "$odir/$fbnam".IO;
        }
    }
    @olist .= sort
}

