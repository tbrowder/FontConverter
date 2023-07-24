Utils;

sub clean-stats(:%afm!, :%t1a!, :%pfb!, :%ttf!, :%otf!, :%pfa!)  is export{
    %afm = [];
    %t1a = [];
    %pfb = [];
    %ttf = [];
    %otf = [];
    %pfa = [];
}

sub clean-outdir($odir) is export {
    my @f = find :dir($odir), :type<file>;
    $_.unlink for @f;
}

sub dir-stats($dir, :%afm, :%t1a, :%pfb, :%ttf, :%otf, :%pfa) is export {
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
