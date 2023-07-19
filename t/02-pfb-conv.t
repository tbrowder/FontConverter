use Test;


use Proc::Easier;
use FontConverter;

my ($args, $res, $pfb);
lives-ok {
    $args = "bin/ff-convert-font";
    $res  = cmd $args;
}

$pfb = "t/fonts/cmbsy10.pfb";
#lives-ok {
    $args = "bin/ff-convert-font $pfb, :output-dir('./t')";
    $res  = cmd $args;
    #note $res.out;
    #note $res.err;
#}

done-testing;
