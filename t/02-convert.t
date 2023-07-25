use Test;

use File::Find;
use File::Temp;
use Proc::Easier;
use FontConverter :test;

use lib <./t/lib>;
use Utils;

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
my ($exe, $args, $res, $pfb, @f, @fo);
$exe = "./bin/fc-convert-font";

lives-ok {
    $args = $exe;
    $res  = cmd($args);
}, "execute, no args";

# testing one input pfb file
subtest {
    clean-outdir($tdir);
    clean-stats(:%afm, :%t1a, :%pfb, :%ttf, :%otf, :%pfa);

    my @in = "t/fonts/CMBSY10.pfb";
    @f     = convert-pfb2ttf @in, :odir("t/out");
    cmp-ok @f.head, '~~', /'.ttf'$/, "got the head .ttf (should be only one)";
    # analyze the output
    my $nf = dir-stats($tdir, :%afm, :%t1a, :%pfb, :%ttf, :%otf, :%pfa);
    is %ttf.elems, 1, "should be only one .ttf";
    is $nf, 1, "should be only one output file";
}, "execute, one pfb in, one ttf expected";

# test multiple, mixed types on command line
subtest {
    clean-outdir($tdir);
    clean-stats(:%afm, :%t1a, :%pfb, :%ttf, :%otf, :%pfa);

    my $o = FontConverter.new;
    my @args = "t/fonts/CMBSY10.pfb", "t/fonts/test1012.otf", 
               "t/fonts/idir/Quicksand-Medium.ttf",
               "out-dir=$tdir";
    $o.run-program: @args;
    # analyze the output
    my $nf = dir-stats($tdir, :%afm, :%t1a, :%pfb, :%ttf, :%otf, :%pfa);
    is $nf, 9;
    is %afm.elems, 2;
    is %t1a.elems, 2;
    is %pfb.elems, 2;
    is %pfa.elems, 2;
    is %ttf.elems, 1;
    is %otf.elems, 0;
}, "multiple, mixed types on command line";

# check fc-convert-font
lives-ok {
    $args = "./bin/fc-convert-font";
    cmd $args;
}, "fc-convert-font";

lives-ok {
    my @args = 
        "t/fonts/CMBSY10.pfb", 
        "t/fonts/test1012.otf", 
        "t/fonts/idir/Quicksand-Medium.ttf",
        "out-dir=$tdir"
    ;
    my $args = @args.join(" ");
    my $eprog = "./bin/fc-convert-font";
    cmd "$eprog $args";
}, "fc-convert-font with args";

lives-ok {
    my @args = 
        "t/fonts/CMBSY10.pfb", 
        "t/fonts/test1012.otf", 
        "t/fonts/idir/Quicksand-Medium.ttf",
        "out-dir=$tdir",
        "in-dir=t/fonts"
    ;
    my $args = @args.join(" ");
    my $eprog = "./bin/fc-convert-font";
    cmd "$eprog $args";
}, "fc-convert-font with args and ovelapping in-dir";

=begin comment
subtest {
    clean-outdir($tdir);
    clean-stats(:%afm, :%t1a, :%pfb, :%ttf, :%otf, :%pfa);
=end comment


=begin comment
# test multiple, mixed types on command line, convert pfb to otf
subtest {
    clean-outdir($tdir);
    clean-stats(:%afm, :%t1a, :%pfb, :%ttf, :%otf, :%pfa);

    my $o = FontConverter.new;
    my @args = "t/fonts/CMBSY10.pfb", "t/fonts/test1012.otf", 
               "out-dir=$tdir", "to-otf";
    $o.run-program: @args;
    # analyze the output
    my $nf = dir-stats($tdir, :%afm, :%t1a, :%pfb, :%ttf, :%otf, :%pfa);
    is $nf, 5;
    is %afm.elems, 1;
    is %t1a.elems, 1;
    is %pfb.elems, 1;
    is %pfa.elems, 1;
    is %ttf.elems, 0;
    is %otf.elems, 1;
}, "multiple, mixed types on command line, convert pfb to otf";
=end comment

done-testing;
=finish

# test multiple, mixed types on command line and an input dir
subtest {
    clean-outdir($tdir);
    clean-stats(:%afm, :%t1a, :%pfb, :%ttf, :%otf, :%pfa);
    my $o = FontConverter.new;
    my @args = "t/fonts/CMBSY10.pfb", "t/fonts/test1012.otf", "in-dir=t/fonts/idir",
               "out-dir=$tdir";
    $o.run-program: @args;
    # analyze the output
    my $nf = dir-stats($tdir, :%afm, :%t1a, :%pfb, :%ttf, :%otf, :%pfa);
    cmp-ok $nf, '>', 1;

}, "test multiple, mixed types on command line and an input dir";

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
dir-stats($tdir, :%afm, :%t1a, :%pfb, :%ttf, :%otf, :%pfa);
# expecting ?
is %ttf.elems, 6;
is %pfb.elems, 4;

done-testing;
