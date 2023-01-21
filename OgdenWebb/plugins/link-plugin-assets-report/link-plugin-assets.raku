use PrettyDump;
sub (%processed, @plugins-used, $processedpod, %options --> Array ) {
    #%.links{$entry}<target location>
    my @report = 'Link report', ;
    for %processed.kv -> $fn, $podf {
        next unless $podf.links and +$podf.links.keys;
        @report.append: "$fn contains links";
        for $podf.links.kv -> $entry, (:$target, :$place, :$link-label, :$type) {
            @report.append: "\t｢$link-label｣ labels a ｢$type｣ link that points to ｢{ $place // 'top' }｣ in target ｢$target｣"
        }
    }
    my @plugs = "Plugin report" , ;
    for @plugins-used {
        @plugs.append: "Plugins used at ｢{ .key }｣ milestone:";
        @plugs.append( "\tNone" ) unless .value.elems;
        for .value.list -> (:key($plug), :value($params)) {
            if $plug ~~ / message / {
                @plugs.append("\t$params")
            }
            else {
                @plugs.append("\t｢$plug｣ called with: " ~ pretty-dump($params.hash).subst(/\n/, "\n\t\t", :g));
            }
        }
    }
    my @templates = "Templates report" , ;
    for %processed.kv -> $fn, $podf {
        next unless $podf.templates-used;
        @templates.append("｢$fn｣ used:");
        # decreasing sort by number of times used
        for $podf.templates-used.sort(- *.value) -> (:key($tmp), :value($times) ) {
            @templates.append("\t$tmp: $times times(s)")
        }
    }
    my @assets = "Assets report" , ;
    my %config = $processedpod.get-data('image');
    my $man = %config<manager>;
    for $man.asset-db.kv -> $nm, %info {
        @assets.append("｢$nm｣ is type { %info<type> } and is used by \n\t " ~ (%info<by> ?? %info<by>.join("\n\t" ) !! 'nothing') )
    }

    ['links-report.txt' => @report.join("\n"),
     'plugins-report.txt' => @plugs.join("\n"),
     'templates-report.txt' => @templates.join("\n"),
     'assets-report.txt' => @assets.join("\n"),
    ]
}