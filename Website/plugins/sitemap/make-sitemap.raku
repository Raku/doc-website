use v6.d;
sub (%processed, @plugins-used, $processed, %options --> Array ) {
    my %config = $processed.get-data('sitemap');
    my $root = %config<root-domain> // '';
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
    ['../../rendered_html/sitemap.xml' => $sitemap ]
}
