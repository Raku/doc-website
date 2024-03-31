use v6.d;
sub ( $pr, %processed, %options) {
    my $sql;
    my %config = $pr.get-data('sqlite-db');
    if $pr.plugin-datakeys (cont) 'tablemanager' {
        my @rows = $pr.get-data('tablemanager').<dataset><routines>.list;
        $sql = q:to/SQL/;
            INSERT INTO routines ( Category, Name, Type, URL )
            VALUES
            SQL
        $sql ~= [~] @rows[0 ^..* ].map({
                '("' ~ .[0] ~ '" , "' ~ .[1] ~ '" , "'~ .[2] ~ '" , "'
               ~ .[3] ~ '#' ~ .[4]
               ~ '")'
               })
               .join(",\n") ~ ";\n";
    }
    else {
        # change the line below to create a string that will cause a better sqlite result
       $sql = 'There is no tablemanager data'
    }
    %config<db-filename>.IO.spurt: $sql;
    [
        [ %config<database-dir> ~ '/schema.sql' , 'myself', 'schema.sql' ],
        [ %config<database-dir> ~ '/' ~ %config<db-filename> , 'myself', %config<db-filename> ]
    ]
}
