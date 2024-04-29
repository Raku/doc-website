use v6.d;
sub ($pr, %processed, %options --> Array ) {
    my @move-files = [];
    if 'metadata.opf'.IO ~~ :e & :f {
        for <metadata.opf toc.xhtml index.xhtml> {
            .IO.unlink;
            note "deleting $_ from ebook-embed" if %options<collection-info>;
        }
    }
    else {
        #| define the order of the sections for ToC and spine
        #| chapter order within section will be alphabetical
        my @section-order = <Opening_opening_opening Language_beginning_Language Language_tutorial_Language
            Language_migration_Language Language_fundamental_Language
            Language_reference_Language Language_advanced_Language
            Programs_programs_programs>;
        #| register all files in ebook
        my @meta;
        #| spine data in order of reading
        my @spine;
        #| register whats to be in spine
        my %spine = @section-order.map( { $_ => [] });
        #| register whats to be in index
        my %index;
        # to get consistent css access for toc and index, they need to be one directory down
        my $book-meta-dir = 'packaging';
        #| register default sections for toc
        my %toc = %(
            'Opening_opening_opening' => %( :name<Introduction>, :contents( [ ] ) ),
            'Language_beginning_Language' => %( :name<Getting started>, :contents( [ ] ) ),
            'Language_migration_Language' => %( :name<Migration guides>, :contents( [ ] ) ),
            'Language_tutorial_Language' => %( :name<Tutorials>, :contents( [ ] ) ),
            'Language_fundamental_Language' => %( :name<Fundamental topics>, :contents( [ ] ) ),
            'Language_reference_Language' => %( :name<General reference>, :contents( [ ] ) ),
            'Language_advanced_Language' => %( :name<Advanced topics>, :contents( [ ] ) ),
            Programs_programs_programs => %( :name<Programs>, :contents( [ ] ) ),
        );
        my $metadata-start = qq:to/META/;
        <?xml version='1.0' encoding='utf-8'?>
        <package dir="ltr" xmlns="http://www.idpf.org/2007/opf" xml:lang="en" unique-identifier="RakuDocumentationEbook" version="3.0">
            <metadata xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/"  xmlns:opf="http://www.idpf.org/2007/opf">
                <dc:creator>The Raku Community</dc:creator>
                <dc:subject>Rakulang</dc:subject>
                <dc:subject>Documentation</dc:subject>
                <dc:identifier id="RakuDocumentationEbook" opf:scheme="uuid">24cb6cd3-e3ff-46cb-9d09-48c414a0a18f</dc:identifier>
                <dc:contributor opf:role="bkp">Collection [https://github.com/finanalyst/Collection]</dc:contributor>
                <dc:title>Raku Canonical Documentation</dc:title>
                <dc:language>en</dc:language>
                <dc:description>The Raku documentation suite in Ebook form</dc:description>
                <dc:author>The Raku Community</dc:author>
                <dc:publisher>Raku Steering Council</dc:publisher>
                <dc:license>Artistic 2.0</dc:license>
                <dc:rightsHolder>The Perl & Raku Foundation</dc:rightsHolder>
                <dc:date>{ DateTime.now.utc }</dc:date>
            </metadata>
            <manifest>
                <item href="{$book-meta-dir}/toc.xhtml" id="toc" media-type="application/xhtml+xml" properties="nav"/>
                <item href="{$book-meta-dir}/index.xhtml" id="index" media-type="application/xhtml+xml"/>
        META
        # add data from css collection to manifest;
        my %data := $pr.get-data('ebook-embed');
        if %data<for-manifest>:exists {
            for %data<for-manifest>.list -> $fn {
                @meta.push: qq[\t\t<item id="$fn" href="$fn" media-type="text/css"></item>\n];
            }
        }
        my $spinedata-start = "\t<spine toc=\"toc\">\n";
        for %processed.kv -> $fn, $podf {
            @meta.push: qq[\t\t<item id="$fn" href="$fn\.xhtml" media-type="application/xhtml+xml"></item>\n];
            # create TOC data
            my $kind = $podf.pod-config-data<kind> // '';
            my $subkind = $podf.pod-config-data<subkind> // '';
            my $cat = $podf.pod-config-data<category> // '';
            my $key = $kind ~ '_' ~ $cat ~ '_' ~ $subkind;
            %spine{ $key } = [] unless %spine{ $key }:exists;
            %spine{ $key }.push: $fn;
            unless %toc{$key}:exists {
                %toc{$key} = %( :contents([ ]), :name(
                    $subkind.tc ~ ' ' ~ $cat ~ ($cat.ends-with('s') ?? 'es' !! 's')
                ) )
            }
            my $fn-link = "../$fn";
            %toc{$key}<contents>.push:
                $pr.tmpl<toc-chapter>.( %( :toc($podf.raw-toc), :$fn-link, :title( $podf.title ) ), $pr.tmpl );
            # consolidate index data
            my %file-glossary = $podf.raw-glossary;
            next unless %file-glossary.keys;
            for %file-glossary.kv -> $entry, @data {
                %index{ $entry } = [] unless %index{ $entry }:exists;
                %index{ $entry }.append: @data.map({ %( .hash, :$fn-link) });
            }
        }
        my $toc-main;
        for @section-order -> $key {
           # remove key data from spine and toc
           my @data = flat( %spine{ $key }:delete );
           for @data.sort {
               @spine.append( qq[\t\t<itemref idref="$_"></itemref>\n] )
           }
           my %data = %toc{ $key }:delete;
           next unless %data<contents>.elems;
           $toc-main ~= $pr.tmpl<toc-section>.( %( :%data, :$key), $pr.tmpl)
        }
        for %toc.sort.map( |*.kv ) -> $key, %data {
            $toc-main ~= $pr.tmpl<toc-section>.( %( :%data, :$key), $pr.tmpl);
            # same key order in spline as in toc
            # there must be an element associated with key to get here
            @spine.append: %spine{$key}.sort.map( qq[\t\t<itemref idref="] ~ * ~ qq["></itemref>\n] )
        }
        $toc-main ~= qq:to/TOC/;
                        <li>
                            <a href="../$book-meta-dir/index.xhtml"><h1>Index</h1></a>
                        </li>
            TOC
        'toc.xhtml'.IO.spurt: $pr.tmpl<ebook-toc>.( %( :$toc-main ), $pr.tmpl );
        'index.xhtml'.IO.spurt: $pr.tmpl<index>.( %( :%index ), $pr.tmpl );
        # add toc and index to spine
        @spine.append: qq[\t\t<itemref idref="index"></itemref>\n], qq[\t\t<itemref idref="toc"></itemref>\n];
        'metadata.opf'.IO.spurt:
            $metadata-start ~ [~] @meta ~ "\t</manifest>\n"
            ~ $spinedata-start ~ [~] @spine ~ "\t</spine>\n</package>\n";
        @move-files = [
            ['metadata.opf', 'myself', 'metadata.opf'],
            ["$book-meta-dir/toc.xhtml", 'myself', 'toc.xhtml'],
            ["$book-meta-dir/index.xhtml", 'myself', 'index.xhtml' ],
        ]
    }
    @move-files
}
