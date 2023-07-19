use Test;

use File::Temp;
use Proc::Easier;
use FontConverter;

my $tdir = "t/out"; # tempdir, :!unlink, :prefix("t");
mkdir $tdir;

my ($args, $res, $pfb, %pfb, %ttf);
lives-ok {
    $args = "bin/ff-convert-font";
    $res  = cmd $args;
}

$pfb = "t/fonts/cmbsy10.pfb";
$args = "bin/fc-convert-font $pfb out-dir=$tdir";
is "$tdir/*.ttf", 
    $res  = cmd $args;
    note $res.out;
    note $res.err;
#}

#done-testing;
