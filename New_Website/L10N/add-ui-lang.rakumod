use v6.d;
use RakuConfig;

proto sub MAIN(|) is export {*}

multi sub MAIN(
        :$config = 'config' #| localised config file
)  {
    my %config;
    if $config.IO ~~ :e & :d {
        %config = get-config(:path( $config ))
    }
    else {
        if $config eq 'config' {
            exit note "Has another config directory been created? \
                If so run ｢{ $*PROGRAM.basename } --config=«installed config directory»｣\
                Or to install run ｢elucid8-build --install｣"
        }
        else { exit note "Cannot proceed without directory ｢$config｣. Try runing ｢elucid8-build --config=$config --install｣ ." }
    }
    my $dict-fn = %config<L10N> ~ '/' ~ %config<ui-dictionary>;
    exit note "$dict-fn does not exist" unless ($dict-fn.IO ~~ :e & :f).so;
    my $new-fn = %config<L10N> ~ '/new-' ~ %config<ui-dictionary>;
    my %dict = EVALFILE( $dict-fn );
    my $canonical = %config<canonical>;
    my @d-langs = %dict.keys.grep({  $_ ne $canonical  });
    # assume that new keys are in canonical AND not in ANY d-langs
    #TODO add check for separate d-langs against canonical
    my @new-keys = ( %dict{ $canonical }.keys (-) %dict{@d-langs.head}.keys ).keys.sort;
    my $sep = @new-keys>>.chars.max;
    my @old-keys = ( %dict{ $canonical }.keys (-) @new-keys ).keys.sort;
    my $rv = '{';
    for $canonical , @d-langs.Slip  -> $lng {
	    $rv ~= "\n\t｢$lng｣ => \{" ~
	        [~] @old-keys.map({ "\n\t\t｢$_｣ => \"{ %dict{$lng }{ $_ } }\"," }) ~
            "\n" ~
	        [~] @new-keys.map({ "\n\t\t｢$_｣{ ' ' x ($sep - $_.chars ) } => \"{($lng eq $canonical) ?? %dict{$canonical}{$_} !! '' } \","}) ~
            "\n\t},"
    }
    $rv ~= "\n}\n";
    $new-fn.IO.spurt: $rv
}
