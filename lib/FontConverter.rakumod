use Proc::Easier;
use File::Find;

unit class FontConverter is export;

# If more than one font arg is entered, 
# they are all checked. Those with suffixes 
# of .ttf or .otf are sent to 'ttf-converter'
# and those with .pfa are to 'ttf2ufm'.
method run-program(@args) is export {
    my $debug  = 0;;
    my $to-otf = 0;
    my %pfb;
    my %ttf;
    my %otf;
    my %other;

    # handle input and output directories
    my $idir; # no default
    my $odir = $*CWD;

    # collect fonts in args
    for @args {
        my $bnam;
        when /'to-otf'/ {
            ++$to-otf;
        }
        when /'in-dir=' (\S+) $/ {
            $idir = ~$0;
            die "FATAL: Input arg in-dir='$idir' is NOT a directory." unless $idir.IO.d;
        }
        when /'out-dir=' (\S+) $/ {
            $odir = ~$0;
            die "FATAL: Input arg out-dir='$odir' is NOT a directory." unless $odir.IO.d;
        }
        when /'.pfb' $/ {
            $bnam = $_.IO.basename;
            %pfb{$bnam} = $_;
        }
        when /'.' [ttf||otf] $/ {
            $bnam = $_.IO.basename;
            %ttf{$bnam} = $_;
        }
        when /:i debug/ {
            ++$debug;
        }
        default {
            %other{$_} = 1;
        }
    }

    if $idir.defined {
        die "FATAL: Input arg in-dir='$idir' is NOT a directory." unless $idir.IO.d;
        # collect files from the input directory
        my @fils = find :dir($idir), :type<file>, :keep-going(True), :name(/'.' [pfb||otf||ttf] $/);
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
        if $to-otf {
            @otf = convert-pfb %pfb.values, :$odir, :$to-otf, :$debug;
        }
        else {
            @ttf = convert-pfb %pfb.values, :$odir, :$debug;
        }
    }
    if %ttf.elems {
        # handle the conversion
        my @f = convert-ttf %ttf.values, :$odir, :$debug;
        @pfb.push: |@f;
    }
    if %otf.elems {
        # handle the conversion
        my @f = convert-ttf %otf.values, :$odir, :$debug;
        @pfb.push: |@f;
    }

    if @pfb {
    }
    if @ttf {
    }
    if @otf {
    }
}

sub convert-pfb(@fonts, :$odir!, :$to-otf = 0, :$debug --> List) {
    note "NOTE: this dir is: '{$odir.IO.absolute}'" if $debug;
    # use ttf-convert (a Python program)
    # to create a .ttf file from a .pba file
    my $eloc1 = %?RESOURCES<bin/ttf-converter>.IO.absolute;
    my $eloc2 = "bin/ttf-converter".IO.absolute;
    my $efil  = $eloc1.IO.r ?? $eloc1 
                            !! $eloc2.IO.r ?? $eloc2 
                                           !! die("FATAL: Unable to open 'ttf-converter'");
    note "DEBUG: Using pfb conversion program '$efil'" if $debug;
    # execute with one or more files
    my $output-dir = "--output-dir $odir";
    my @ofils;
    if not $to-otf {
        my $args = $output-dir ~ " " ~ @fonts.join(" ");
        my $exe  = "$efil $args";
        my $res  = cmd $exe;
        @ofils = find :dir($odir), :type<file>, :name(/'.ttf'$/);
    }
    else {
        # must do it the hard way for mow: one exe per file
        for @fonts -> $font {
            my $fnam = $font.IO.basename;
            $fnam ~~ s/.pfb$/.otf/;
            my $args = "$output-dir $font $fnam";
            my $exe  = "$efil $args";
            my $res  = cmd $exe;
            my $ofil = "$odir/$fnam";
            @ofils.push: $ofil;
        }

    }
    @ofils
}

sub convert-ttf(@fonts, :$odir!, :$debug --> List) {
    note "NOTE: this dir is: '{$odir.IO.absolute}'" if $debug;
    # use ttf2ufm to create a .pba file 
    # from a .ttf or .otf file
    my $eprog = "ttf2ufm";
    note "DEBUG: Using ttf/otf pfb conversion program '$eprog'" if $debug;
    # each file has to be handled separately with two executions

    # set $*OUT to $odir
    $*OUT = $odir;
    for @fonts -> $font {
        my $args1 = "--pfb -G u $font";
        my $exe1  = "$eprog $args1";
        my $res1  = cmd $exe1;
        my $args2 = "-G u $font";
        my $exe2  = "$eprog $args2";
        my $res2  = cmd $exe2;
    }
}


