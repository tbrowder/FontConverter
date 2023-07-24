use Test;

use File::Find;
use File::Temp;
use Proc::Easier;
use FontConverter :test;

my $debug = 1;
my $tdir;
if $debug {
    $tdir = "t/out";
    mkdir $tdir;
}
else {
    $tdir = tempdir;
}

# stats in the 't/fonts' and 't/fonts/idir' directories
my (%afm1, %t1a1, %pfb1, %ttf1, %otf1, %pfa1);
my (%afm2, %t1a2, %pfb2, %ttf2, %otf2, %pfa2);

# check stats from input dirs
subtest {
    dir-stats("t/fonts", :afm(%afm1), :t1a(%t1a1), :pfb(%pfb1), :ttf(%ttf1), :otf(%otf1), :pfa(%pfa1));
    is %afm1.elems, 2;
    is %t1a1.elems, 2;
    is %pfb1.elems, 3;
    is %ttf1.elems, 1;
    is %otf1.elems, 1;
    is %pfa1.elems, 0;
}, "checking correct input in dir 't/fonts'";

subtest {
    dir-stats("t/fonts/idir", :afm(%afm2), :t1a(%t1a2), :pfb(%pfb2), :ttf(%ttf2), :otf(%otf2), :pfa(%pfa2));
    is %afm2.elems, 2;
    is %t1a2.elems, 2;
    is %pfb2.elems, 3;
    is %ttf2.elems, 1;
    is %otf2.elems, 1;
    is %pfa2.elems, 0;
}, "checking correct input in dir 't/fonts/idir'";

my (%afm, %t1a, %pfb, %ttf, %otf, %pfa);

sub clean-stats {
    %afm = [];
    %t1a = [];
    %pfb = [];
    %ttf = [];
    %otf = [];
    %pfa = [];
}

sub clean-outdir {
    my @f = find :dir($tdir), :type<file>; 
    $_.unlink for @f
}

sub dir-stats($dir, :%afm, :%t1a, :%pfb, :%ttf, :%otf, :%pfa) {
    # limit the search to one directory
    my @f  = find :$dir, :recursive(False), :type<file>;
    for @f {
        my $bnam = $_.basename;
        when /'.' afm $/ { %afm{$bnam} = $_ }
        when /'.' t1a $/ { %t1a{$bnam} = $_ }
        when /'.' pfb $/ { %pfb{$bnam} = $_ }
        when /'.' ttf $/ { %ttf{$bnam} = $_ }
        when /'.' otf $/ { %otf{$bnam} = $_ }
        when /'.' pfa $/ { %pfa{$bnam} = $_ }
        default {
            die "FATAL: Unknown file type '$_'";
        }
    }
    # get the total files found
    %afm.elems + %t1a.elems + %pfb.elems + %ttf.elems + %otf.elems + %pfa.elems;
}


my ($exe, $args, $res, $pfb, @f, @fo);
$exe = "./bin/fc-convert-font";

lives-ok {
    $args = $exe;
    $res  = cmd($args);
}, "execute, no args";

# testing one input pfb file
subtest {
    clean-outdir;
    clean-stats;
    my @in = "t/fonts/CMBSY10.pfb";
    @f     = convert-pfb2ttf @in, :odir("t/out");
    cmp-ok @f.head, '~~', /'.ttf'$/, "got the head .ttf (should be only one)";
    # analyze the output 
    my $nf = dir-stats($tdir, :%afm, :%t1a, :%pfb, :%ttf, :%otf);
    is %ttf.elems, 1, "should be only one .ttf";
    is $nf, 1, "should be only one output file";
}, "execute, one pfb in, one ttf expected";

clean-outdir;
clean-stats;

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
