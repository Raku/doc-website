use v6.d;
sub (%processed, @plugins-used, $processed, %options --> Array ) {
    my %config = $processed.get-data('sitemap');
    exit note 'Sitemap plugin error. Must set configuration for ｢root-domain｣ and  ｢sitemap-destination｣'
        unless %config<root-domain>:exists and %config<sitemap-destination>:exists;
    my $root = %config<root-domain>;
    my $dest = %config<sitemap-destination>;
    my $sitemap = q:to/START/;
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    START
    my $priority;
    for %processed.keys -> $fn {
        given $fn {
            when any(< introduction reference miscellaneous > ) { $priority = 0.8 }
            when / ^ 'language/' / { $priority = 0.7 }
            when / ^ 'type/' / { $priority = 0.6 }
            default { $priority = 0.5 }
        }
        $sitemap ~= qq:to/URL/;
            <url>
                <loc>$root/$fn/\</loc>
                <priority>$priority\</priority>
            </url>
        URL
    }

    $sitemap ~= q:to/END/;
    </urlset>
    END
    # return array of pairs
    ["$dest/sitemap.xml" => $sitemap ]
}
