use Proc::Easier;
use File::Find;

unit class FontConverter;

my $DEBUG = 0;

# If more than one arg is entered, 
# they are all checked. If none
# are .ttf or .otf, all inputs are sent to 'ttf-converter'.
# Othewise, all must be .pfa fonts and sent to 'ttf2ufm'.
method run-program(@args, :$output-dir, :$input-dir) is export {
    return if not @args.elems;

    my @a = @args;
    my %pfb;
    my %ttf;
    my %other;

    # handle the input and output directories
    my ($odir, $idir);
    if $output-dir.defined {
        $odir = $output-dir;
        die "FATAL: Input arg '$odir' is NOT a directory." unless $odir.IO.d;
    }
    if $input-dir.defined {
        $idir = $input-dir;
        die "FATAL: Input arg '$idir' is NOT a directory." unless $idir.IO.d;
        # collect files from the input directory
        my @fils = find :dir($idir), :type<file>, :keep-going(True), :name(/"." [pfb||otf||ttf] $/);
    }
    
    for @a -> $a {
        my ($suf);
        if $a ~~ / '.' (\S+) $/ {
            if $suf ~~ /pfb/ {
                die "FATAL: Input arg '$a' is NOT a font file." unless $a.IO.r;
                # then save it
                %pfb{$a} = 1;
            }
            elsif $suf ~~ /[o|t] tf/ {
                die "FATAL: Input arg '$a' is NOT a font file." unless $a.IO.r;
                # then save it
                %ttf{$a} = 1;
            }
            else {
                %other{$a} = 1;
            }
        }
        else {
            %other{$a} = 1;
        }
    }

    # Ensure we have the proper separation of program arguments.
    # For now, we ignore all args except type, and only run
    # one conversion type until we can have output directory control.
    if %pfb.elems and %ttf.elems {
        say "ERROR: Cannot handle mixed conversion types at the moment.";
        say "       Please file an issue if this is important to you.";
        say "       Exiting.";
        exit;
    }
    elsif %pfb.elems {
        # handle the conversion
        convert-pfb %pfb.keys.join(" ");
    }
    elsif %ttf.elems {
        # handle the conversion
        convert-ttf %ttf.keys.join(" ");
    }
    else {
        say "ERROR: No .pfb or .ttf or .otf files found in the input args.";
        say "       Exiting.";
        exit;
    }
}

sub convert-pfb(@fonts) {
    note "NOTE: this dir is: ", $*CWD.IO.absolute if $DEBUG;
    # use ttf-convert (a Python program)
    # to create a .ttf file from a .pba file
    my $eloc1 = %?RESOURCES<bin/ttf-converter>.IO.absolute;
    my $eloc2 = "bin/ttf-converter".IO.absolute;
    my $efil  = $eloc1.IO.r ?? $eloc1 
                            !! $eloc2.IO.r ?? $eloc2 
                                           !! die("FATAL: Unable to open 'ttf-converter'");
    note "DEBUG: Using pfb conversion program '$efil'" if $DEBUG;
    # execute with one or more files
    my $args = @fonts.join(" ");
    my $exe  = "$efil $args";
    my $res  = cmd $exe;
    note $res.raku;
}

sub convert-ttf(@fonts) {
    note "NOTE: this dir is: ", $*CWD.IO.absolute;
    # use ttf2ufm to create a .pba file 
    # from a .ttf or .otf file
    my $eprog = "ttf2ufm";
    note "DEBUG: Using ttf/otf pfb conversion program '$eprog'" if $DEBUG;
    # execute with one or more files
    my $args = @fonts.join(" ");
    my $exe  = "$eprog $args";
    my $res  = cmd $exe;
    note $res.raku;
}


