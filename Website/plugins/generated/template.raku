#!/usr/bin/env raku
use v6.d;
%(
    generated => sub (%prm, %tml) {
        qq[[
        <div class="collection-generated">
        { %prm<raw-contents> // '' }
        <ul>
            <li>Based on <a href="https://github.com/Raku/doc">Raku/doc (documentation content)</a> source commit { %prm<generated><commit-id>.trim }.</li>
            <li>Based on <a href="https://github.com/Raku/doc-website">Raku/doc-website (website tooling)</a> source commit: { %prm<generated><mode-commit-id>.trim}.</li>
            <li>Generated on { %prm<generated><g-date> } at { %prm<generated><g-time> } UTC.</li>
        </ul>
        </div>
        ]]
    }
)