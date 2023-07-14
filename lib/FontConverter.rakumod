use Proc::Easier;

unit class FontConverter;


my @args = @*ARGS;
my $o    = FontConvert.new;
$o.run-program @args;

# If more than one arg is entered, 
# one is checked for a "=d" for
# debug, otherwise they are 
# ignored.
method run-program(@args) is export {
    my @a     = @args;
    my $debug = 0:
    my $font;
    my $a = @a.shift;
    if $a ~~ /'=debug=/ {
        ++$debug;
        $a = @a.shift;
        $font = $a;
        @a = [];
    }
    
    if @a.elems {
        $a = #a.shift;
        # the first must have been the font or debug
        if $debug {
            $font = $a;
        }
        elsif $font.defined {
            if $a ~~ /'=debug=/ {
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
}

sub convert-ttf($font) {
}


