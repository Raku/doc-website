use v6.d;
use Pod::Load;
my regex preface {
    ^ (.+) \n \-+ $$
}
my regex value { .+? }
my regex name {
    ^^ 'N:' \s* <value> \v
}
my regex email {
    ^^ 'E:' \s* <value> \v
}
my regex desc {
    ^^ 'D:' \s* <value> \v
}
my regex github {
    ^^ 'U:' \s* <value> \v
}
my regex website {
    ^^ 'W:' \s* <value> \v
}
my regex smail {
    ^^ 'S:' \s* <value> \v
}
my regex detail {
    <name> | <email> | <website> | <desc> | <github> | <smail>
}
my regex contributor {
    <detail>+ \v
}

sub ($source-cache, $mode-cache, Bool $full-render,  $source-root, $mode-root, %p-options, %options) {
    my $fn = "{ $*CWD.parent.parent.parent }/CREDITS";
#    my $fn = "trial/CREDITS";
    return unless $fn.IO ~~ :e & :f;
    my $contents = $fn.IO.slurp ~ "\n\n";
    $contents ~~ / ^ <preface> \s* <contributor>+ \s* $ /;
    my $preface = $/<preface>[0].Str;
    my @contributors = [
        %(  :name<Name>, :github('Github user-name'), :email<Email>,
            :desc<Description>, :website<Website>, :smail('Snail mail') ),
    ];
    for $/<contributor> {
        my %info;
        for $_.<detail> {
            for .kv -> $k, $v {
                %info{ $k.Str } = $v.<value>.Str;
            }
        }
        @contributors.push: %info;
    }
    my %widths = %( gather for @contributors[0].keys -> $k {
        take $k => max( @contributors.map({ with .{ $k } { .chars } }))
    } );
    my $table = "=begin table\n";
    my $first = 0;
    my @order = <github name desc email website>;
    my $format = @order.map({ '%' ~ %widths{$_} ~ 's ' }).join('| ') ~ "\n";
    my $full-wid = '=' x (( [+] %widths.values) + 3 * %widths.elems) ~ "\n";
    for @contributors -> %inf {
        my @row = @order.map({ %inf{$_} // '' });
        $table ~= sprintf( $format, @row );
        $table ~= $full-wid unless $first++ ;
    }
    $table ~= "\n=end table";
    $mode-cache.add('Website/structure-sources/credits.rakudoc', load(qq:to/RAKUDOC/));
    =begin pod :no-toc :no-glossary
    =TITLE Contributors
    =SUBTITLE File generated from CREDITS text

    $table
    =end pod
    RAKUDOC
}
