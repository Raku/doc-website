sub ($pp, %options) {
    my $css = '';
    my @links;
    my @adds;
    for $pp.plugin-datakeys -> $p {
        next if $p eq 'gather-css';
        my $data = $pp.get-data($p);
        next unless $data ~~ Associative;
        with $data<css> {
            when Str:D {
                my $file = ($data<path> ~ '/' ~ $_).IO;
                $css ~= "\n" ~ $file.slurp
            }
            when Positional {
                for .list {
                    my $file = ($data<path> ~ '/' ~ $_).IO;
                    $css ~= "\n" ~ $file.slurp
                }
            }
        }
        with $data<css-link> {
            when Str:D { @links.append: $_ }
            when Positional { @links.append: .list }
        }
        with $data<add-css> {
            when Str:D { @adds.push( ($p  , $_ ) ) } # only name of plugin needed. path found later by Collection
            when Positional { @adds.push( ($p , $_ ) ) for .list }
        }
    }
    return () unless $css or +@adds or +@links;
    my $template = '%( css => sub (%prm, %tml) {';
    my @move-dest;
    if $css {
        # remove any .ccs.map references in text as these are not loaded
        $css.subst-mutate(/ \n \N+ '.css.map' .+? $$/, '', :g);
        my $fn = $pp.get-data('mode-name') ~ '.css';
        $fn.IO.spurt($css);
        $template ~= "\n" ~ '"\n" ~ ' ~ "'<link rel=\"stylesheet\" href=\"/assets/css/$fn\"/>'";
        @move-dest.push( ("assets/css/$fn", 'myself', $fn , ) )
    }
    else { $template ~= ' "" ' } # Template is describing a subroutine that emits a string, which must be started by css
    for @adds {
        my $link-title  = do given $_[1] { when /light/ { ' title="light"' }; when /dark/ { ' title="dark"' }; default { "" }};
        $template ~= "\n" ~ '~ "\n" ~ ' ~ "'<link rel=\"stylesheet\" href=\"/assets/css/{ $_[1] }\"{ $link-title }/>'";
        @move-dest.push( ('assets/css/' ~ $_[1], $_[0], $_[1], ) )
    }
    for @links {
        $template ~= "\n" ~ '~ "\n" ~ ' ~ "'<link rel=\"stylesheet\" $_ />'";
    }
    $template ~= "\n" ~ '~ "\n" },)';
    "css-templates.raku".IO.spurt: $template;
    @move-dest
}
