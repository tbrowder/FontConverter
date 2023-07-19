use Proc::Easier;
use File::Find;

unit class FontConverter;

# If more than one font arg is entered, 
# they are all checked. Those with suffixes 
# of .ttf or .otf are sent to 'ttf-converter'
# and those with .pfa are to 'ttf2ufm'.
method run-program(@args) is export {
    my $debug;
    my %pfb;
    my %ttf;   # includes .otf
    my %other;

    # handle input and output directories
    my $idir; # no default
    my $odir = $*CWD;

    # collect fonts in args
    for @args {
        my $bnam;
        when /'in-dir=' (\S+) $/ {
            $idir = $_;
            die "FATAL: Input arg in-dir='$idir' is NOT a directory." unless $idir.IO.d;
        }
        when /'out-dir=' (\S+) $/ {
            $odir = $_;
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
            when /'.' [ttf||otf] $/ {
                $bnam = $_.IO.basename;
                %ttf{$bnam} = $_;
            }
        }
    }

    # Check input font files results
    if not (%pfb.elems or %ttf.elems) {
        say "ERROR: No .pfb, .ttf, or .otf files found via the input args.";
        say "       Exiting.";
        exit;
    }

    # Finally, do the conversions
    my (@ttf, @pfb);
    if %pfb.elems {
        # handle the conversion
        @ttf = convert-pfb %pfb.values, :$debug;
    }
    if %ttf.elems {
        # handle the conversion
        @pfb = convert-ttf %ttf.values, :$debug;
    }

    if @pfb {
    }
    if @ttf {
    }

}

sub convert-pfb(@fonts, :$out-dir!, :$debug) {
    note "NOTE: this dir is: '{$out-dir.IO.absolute}'" if $debug;
    # use ttf-convert (a Python program)
    # to create a .ttf file from a .pba file
    my $eloc1 = %?RESOURCES<bin/ttf-converter>.IO.absolute;
    my $eloc2 = "bin/ttf-converter".IO.absolute;
    my $efil  = $eloc1.IO.r ?? $eloc1 
                            !! $eloc2.IO.r ?? $eloc2 
                                           !! die("FATAL: Unable to open 'ttf-converter'");
    note "DEBUG: Using pfb conversion program '$efil'" if $debug;
    # execute with one or more files
    my $args = @fonts.join(" ");
    my $exe  = "$efil $args";
    my $res  = cmd $exe;
    note $res.raku;
}

sub convert-ttf(@fonts, :$out-dir!, :$debug) {
    note "NOTE: this dir is: '{$out-dir.IO.absolute}'" if $debug;
    # use ttf2ufm to create a .pba file 
    # from a .ttf or .otf file
    my $eprog = "ttf2ufm";
    note "DEBUG: Using ttf/otf pfb conversion program '$eprog'" if $debug;
    # each file has to be handled separately with two executions
    for @fonts -> $font {
        my $args1 = "--pfb -G u $font";
        my $exe1  = "$eprog $args1";
        my $res1  = cmd $exe1;
        my $args2 = "-G u $font";
        my $exe2  = "$eprog $args2";
        my $res2  = cmd $exe2;
        note $res1.raku;
        note $res2.raku;
    }
}


