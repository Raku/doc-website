%(
    image => sub (%prm, %tml) {
        my %config = %prm<image>;
        exit note ('Unexpected. Did not get a valid image. Got ' ~ %prm<src>)
            unless %config<manager>.asset-is-used(%prm<src>,'image');
        '<div class="image-container ' ~
        ~ ( %prm<class>:exists ?? %prm<class> !! '' )
        ~ '"><img src="' ~ %config<dest-dir> ~ '/' ~ %prm<src> ~  '"'
        ~ ' alt="' ~ (%prm<contents> // '') ~ '"'
        ~ ( %prm<id>:exists ?? (' id"' ~ %prm<id>  ~ '"') !! '' )
        ~ '></div>'
    },
)