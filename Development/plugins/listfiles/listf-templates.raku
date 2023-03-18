use v6.d;
my regex s-pair {
    (\S+?) \s* \= \s* (\S+)
};
my regex select {
    ^ <s-pair>+ % [\,\s] $
};

%(
    listfiles => sub (%prm, %tml) {
        return qq:to/ERROR/ unless %prm<select>:exists;
            <div class=\"listf-error\">ListFiles needs :select key with criteria. Got:
            ｢{ %prm.grep({ .key ~~ none(<contents target listfiles render>) }).raku }｣
            and collected data, is ｢listfiles｣ in the Mode's ｢plugins-required<compilation>｣ list?
            </div>
            ERROR

        my $sel = %prm<select>;
        my %criteria;
        if $sel ~~ / <select> / {
            for $/<select><s-pair> { %criteria{~$_[0]} = ~$_[1] }
        }
        else {
            return qq:to/ERROR/
                <div class="listf-error">
                ListFiles :select key does not parse, must be one pair of form ｢\\S+ \\s* = \\s* \\S+｣
                or a comma-separated list of such pairs. Got
                { %prm<select> }
                </div>
                ERROR

             }
        # check meta data exists
        return q:to/ERROR/ unless %prm<listfiles><meta>:exists;
            <div class="listf-error">ListFiles has no collected data,
            is ｢listfiles｣ in the Mode's ｢plugins-required<compilation>｣ list?
            </div>
            ERROR

        my @sel-files;
        for %prm<listfiles><meta>.kv -> $fn, %data {
            # data is config, title, desc
            my Bool $ok;
            for %criteria.kv -> $k, $v {
                $ok = (%data<config>{$k}:exists and ?(%data<config>{$k} ~~ / <$v> /));
                last unless $ok
            }
            next unless $ok;
            @sel-files.push: [
                ((%data<title> eq '' or %data<title> eq 'NO_TITLE') ?? $fn !! %data<title> ),
                (%data<desc> ?? %data<desc> !! (%prm<no-desc> ?? %prm<no-desc> !! 'No description found')),
                $fn
            ];
        }
        my $rv = qq:to/FIRST/;
                <div class="listf-container">
                <div { %prm<target> ?? ('id="' ~ %tml<escaped>(%prm<target>) ~ '"') !! '' }
                  class="listf-caption">{ %prm<contents> // '' }</div>
                FIRST

        for  @sel-files.sort(*.[0]) -> ($nm, $desc, $path) {
            $rv ~= '<div class="listf-file"><a class="listf-link" href="' ~ $path ~ '.html">' ~ $nm ~ '</a></div>'
                    ~ '<div class="listf-desc">' ~ $desc ~ '</div>'
        }
        unless +@sel-files {
            $rv ~= '<div class="listf-file">'
                    ~ (%prm<no-files> ?? %prm<no-files> !! 'No files meet the criteria')
                    ~ '</div>'
        }
        $rv ~= '</div>'
    },
)