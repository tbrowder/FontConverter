use Proc::Easier;

unit class FontConverter;

my @args = @*ARGS;
my $o    = FontConverter.new;
$o.run-program: @args;

# If more than one arg is entered, 
# one is checked for a "=d" for
# debug, otherwise they are 
# ignored.
method run-program(@args) is export {
    my @a     = @args;
    my $debug = 0;
    my $font;
    my $a = @a.shift // '';
    return if not $a;

    if $a ~~ /'=debug='/ {
        ++$debug;
        $a = @a.shift;
        $font = $a;
        @a = [];
    }
    
    if @a.elems {
        $a = @a.shift;
        # the first must have been the font or debug
        if $debug {
            $font = $a;
        }
        elsif $font.defined {
            if $a ~~ /'=debug='/ {
                ++$debug;
            }
        }
    }
    # check that $font is (1) a known name format and (2) a readable file
    # check for known, convertible file extensions
    my $suf;
    if $font ~~ / '.' (\S+) $/ {
        $suf = ~$0;
        with $suf {
            when /pfb/ {
                ; # ok
            }
            when /[o|t] tf/ {
                ; # ok
            }
            default {
                note "FATAL: Unrecognized file extension '$_'";
                exit;
            }
        }
    }
    # check for a valid, readable file
    if not $font.IO.r {
        note "FATAL: Unrecognized file extension '$_'";
        exit;
    }

    # handle the conversion
    if $suf ~~ /pfb/ {
        convert-pfb $font
    }
    elsif $suf ~~ /[t|o] tf/ {
        # ttf2ufm
        convert-ttf $font
    }
    else {
        die "FATAL: Unknown suffix '$suf'";
    }
}

sub convert-pfb($font) {
    # use ttf-convert (a Python program)
    # to create a .ttf file from a .pba file
    my $tloc1 = %?RESOURCES<bin/ttf-converter>.absolute.IO.r // False;
    my $tloc2 = "../../bin/ttf-converter".IO.r // False;
    my $tfil = $tloc1 ?? $tloc1 
                      !! $tloc2 ?? $tloc2 
                                !! die("FATAL: Unable to open 'ttf-converter'");
}

sub convert-ttf($font) {
    # use ttf2ufm to create a .pba file 
    # from a .ttf file
}


