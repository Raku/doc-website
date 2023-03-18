%(
    format-f => sub (%prm, %tml) {
        "<span class=\"fa { %prm<contents> // 'fa-question-circle-o'} { %prm<meta> // ''}\"></span>"
    },
)