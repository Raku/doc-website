sub ( $pp, %options ) {
    my Bool $loadjq-lib = False;
    my @js;
    my @js-bottom;
    my multi sub add-defn(:$field, Positional :$info, :$plug, :$order = 0) {
        if $info[1] ~~ Str {
            add-defn(:$field, :info( $info[0] ), :$plug );
            add-defn(:$field, :info( $info[1] ), :$plug )
        }
        elsif $info[1] ~~ Int {
            add-defn(:$field, :info( $info[0] ), :order( $info[1]), :$plug)
        }
        else {
            note "[{$?FILE.IO.basename}] ignoring invalid '$field' config data from ｢$plug｣, because ｢{ $info.raku }｣ is not valid" ;
        }
    }
    my multi sub add-defn(:$field, Str:D :$info, :$plug, :$order = 0 ) {
        given $field {
            when 'js-script' {
                @js.push( ($info, $plug, $order ) )
            };
            when 'js-link' {
                @js.push( ($info, '', $order ) )
            }
            when 'js-bottom' {
                @js-bottom.push(( $info, $plug, $order ));
            }
            when 'jquery' {
                @js.push(( $info, $plug, $order ));
                $loadjq-lib = True
            }
            when 'jquery-link' {
                @js.push( ($info, '', $order ) );
                $loadjq-lib = True
            }
        }
    }
    my %own-config = $pp.get-data('gather-js-jq');
    for $pp.plugin-datakeys -> $plug {
        next if $plug eq 'js-collator' ;
        my $data = $pp.get-data($plug);
        next unless $data ~~ Associative;
        for $data.kv -> $field, $info {
            next unless $field ~~ any(<js-link js-script js-bottom jquery jquery-link>);
            unless $field ~~ Str:D | Positional {
                note "[{$?FILE.IO.basename}] ignoring invalid '$field' config data from ｢$plug｣, because ｢{ $info.raku }｣ is not Str or Positional" ;
                next
            }
            if $info ~~ Str:D {
                 add-defn(:$field, :$info, :$plug )
            }
            else {
                # handle higher order parameters or list
                # if data entry is a Positional, then it can be either a list of items, mixing Array and Strings,
                my @inf = $info.list;
                if @inf.elems == 2 and @inf[1] !~~ Positional {
                    add-defn( :$field, :$plug, :$info);
                }
                else {
                    while @inf.elems {
                        add-defn( :$field, :$plug, :info( @inf.shift ) );
                    }
                }
            }
        }
    }
    my $template = "\%( \n "; # empty list emitted if not jq/js
    $template ~= 'jq-lib => sub (%prm, %tml) {'
        ~ "\n\'\<script src=\"" ~ %own-config<jquery-lib> ~ '"></script>' ~ "\' \n},\n"
        if $loadjq-lib;
    my @move-dest;
    my $elem;
    for @js.sort({.[2]}) -> ($file, $plug, $order ){
        FIRST {
            $template ~= 'js => sub (%prm, %tml) {' ;
            $elem = 0;
        }
        LAST {
            $template ~= "},\n"
        }
        $template ~= ( $elem ?? '~ ' !! '' )
                ~ '\'<script '
                ~ ( $plug ?? 'src="/assets/scripts/' !! '' )
                ~ $file
                ~ ( $plug ?? '"' !! '' )
                ~ ">\</script>'\n";
        ++$elem;
        @move-dest.push( ("assets/scripts/$file" , $plug, $file ) )
            if $plug
    }
    for @js-bottom.sort({.[2]}) -> ($file, $plug ){
        FIRST {
            $template ~= 'js-bottom => sub (%prm, %tml) {' ;
            $elem = 0;
        }
        LAST {
            $template ~= "},\n"
        }
        $template ~= ( $elem ?? '~ ' !! '' ) ~ '\'<script src="/assets/scripts/' ~ $file ~ "\"\>\</script>'\n";
        ++$elem;
        @move-dest.push( ("assets/scripts/$file", $plug, $file ) )
    }
    $template ~= ")\n";
    "js-templates.raku".IO.spurt($template);
    @move-dest
}