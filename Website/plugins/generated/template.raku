#!/usr/bin/env raku
use v6.d;
%(
    generated => sub (%prm, %tml) {
        qq[[
        <div class="collection-generated">
        { %prm<raw-contents> // '' }
        <ul>
            <li>Based on commit { %prm<generated><commit-id>.trim }.</li>
            <li>Generated on { %prm<generated><g-date> } at { %prm<generated><g-time> } UTC.</li>
        </ul>
        </div>
        ]]
    }
)