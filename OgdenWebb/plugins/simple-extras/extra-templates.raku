#
#some extra templates that seemed useful
use v6.d;
%(
    hr => sub (%prm, %tml) {
        if %prm<class>:exists { '<hr class="' ~ %prm<class> ~ '"/>' }
        else { '<hr/>' }
    },
    quotation => sub (%prm, %tml) {
        #remove <p> and </p>
        my $data = %prm<contents>.subst(/^\<p\>/, '');
        $data .=subst(/\<\/p\> \s* $/, '');
        $data .=subst(/'\n'/, '<br>', :g);
        my $auth = %prm<author> // '';
        ($auth = "<br><span class=\"author\">$auth\</span>") if $auth;
        my $cita = %prm<citation> // '';
        ($cita = "<br><span class=\"citation\">$cita\</span>") if $cita;
        qq:to/QUOT/;
            \<p class="quotation">{ $data ~ $auth ~ $cita }\</p>
            QUOT
    },
    flex-container => sub (%prm, %tml) {
        '<div class="flex-container">' ~ %prm<contents> ~ '</div>'
    }
);

