use Test;

use File::Find;
use File::Temp;
use Proc::Easier;
use FontConverter;

my $debug = 1;

# stats in the 't/fonts' and 't/fonts/idir' directories
my (%afm1, %t1a1, %pfb1, %ttf1, %otf1);
my (%afm2, %t1a2, %pfb2, %ttf2, %otf2);

# check stats from input dirs
dir-stats("t/fonts", :afm(%afm1), :t1a(%t1a1), :pfb(%pfb1), :ttf(%ttf1), :otf(%otf1));
is %afm1.elems, 2;
is %t1a1.elems, 2;
is %pfb1.elems, 3;
is %ttf1.elems, 1;
is %otf1.elems, 1;

dir-stats("t/fonts/idir", :afm(%afm2), :t1a(%t1a2), :pfb(%pfb2), :ttf(%ttf2), :otf(%otf2));
is %afm2.elems, 2;
is %t1a2.elems, 2;
is %pfb2.elems, 3;
is %ttf2.elems, 1;
is %otf2.elems, 1;

my (%afm, %t1a, %pfb, %ttf, %otf);

sub clean-stats {
    %afm = [];
    %t1a = [];
    %pfb = [];
    %ttf = [];
    %otf = [];
}

sub clean-outdir {
    my @f = find :dir("t/out"), :type<file>; 
    $_.unlink for @f
}

sub dir-stats($dir, :%afm, :%t1a, :%pfb, :%ttf, :%otf) {
    # limit the search to one directory
    my @f  = find :$dir, :recursive(False), :type<file>;
    for @f {
        my $bnam = $_.basename;
        when /'.' afm $/ { %afm{$bnam} = $_ }
        when /'.' t1a $/ { %t1a{$bnam} = $_ }
        when /'.' pfb $/ { %pfb{$bnam} = $_ }
        when /'.' ttf $/ { %ttf{$bnam} = $_ }
        when /'.' otf $/ { %otf{$bnam} = $_ }
        default {
            die "FATAL: Unknown file type '$_'";
        }
    }
}

my $tdir;
if $debug {
    $tdir = "t/out";
    mkdir $tdir;
}
else {
    $tdir = tempdir;
}

my ($exe, $args, $res, $pfb, @f, @fo);
$exe = "./bin/fc-convert-font";

lives-ok {
    $args = $exe;
    $res  = cmd $args;
}, "execute, no args";

# testing one input pfb file
clean-outdir;
clean-stats;
lives-ok {
    $pfb  = "t/fonts/cmbsy10.pfb";
    $args = "$exe $pfb out-dir=$tdir";
    $res  = cmd $args;
}, "execute, one pfb in, one ttf expected";
# analyze the output 
dir-stats($tdir, :%afm, :%t1a, :%pfb, :%ttf, :%otf);
is %ttf.elems, 1;

done-testing;
=finish

clean-outdir;
clean-stats;
my ($tafm, $ttia, $tpfb, $tttf, $totf);
$tpfb = %pfb1.elems;
$tttf = %ttf1.elems;
$totf = %otf1.elems;
is $tpfb, 6;
is $tttf, 2;
is $totf, 2;
lives-ok {
    $args = "$exe in-dir=t/fonts out-dir=$tdir";
    $res  = cmd $args;
}, "input (pfb, ttf, otf): $tpfb, $tttf, $totf";
# analyze the output 
# stats from output
dir-stats($tdir, :%afm, :%t1a, :%pfb, :%ttf, :%otf);
# expecting ?
is %ttf.elems, 6;
is %pfb.elems, 4;

done-testing;
