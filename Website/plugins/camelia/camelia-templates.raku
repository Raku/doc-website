use v6.d;
%(
    'camelia-img' => sub ( %prm, %tml ) { '<img id="Camelia_bug" src="/assets/images/Camelia.svg">' },
    'favicon' => sub ( %prm, %tml ) {
        "\n<link" ~ ' href="/assets/images/Camelia.ico" rel="icon" type="image/x-icon"' ~ "/>\n"
    },
    'camelia' => sub (%prm, %tml ) {
        '<img src="/assets/images/Camelia.svg" class="' ~ ( %prm<class> // 'camelia') ~ "\">\n"
    },
    'cameliafaded' => sub (%prm, %tml ) {
        '<img src="/assets/images/Camelia-faded.svg" class="' ~ ( %prm<class> // 'camelia') ~ "\">\n"
    },
    'cameliashadow' => sub (%prm, %tml ) {
        '<img src="/assets/images/Camelia-404.png" class="' ~ ( %prm<class> // 'camelia') ~ "\">\n"
    },
)