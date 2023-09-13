use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::HTTP::Log::File;
use RakuConfig;

sub ( $destination, $landing, $ext, %p-config, %options ) {
    if (try require Cro::HTTP::Router) === Nil {
        exit note "Cro::HTTP needs to be installed"
    }
    my %config = get-config;
    my $host = %p-config<cro-app><host> // %config<host>;
    my $port = %p-config<cro-app><port> // %config<port>;
    my %map;
    my @urls;
    for %p-config<cro-app><url-map>.list {
        if ("$destination/$_".IO ~~ :e & :f) {
            for "$destination/$_".IO.lines {
                if m/ \" ~ \" (.+?) \s+ \" ~ \" (.+) / {
                    %map{ ~$0 } = ~$1;
                }
            }
        }
    }
    @urls = %map.keys;
    my $app = route {
        get -> *@path {
            my $url = '/' ~ @path.join('/');
            @path = (%map{$url},) if $url ~~ any(@urls);
            @path[*- 1] ~= ".$ext"
                unless @path[0] eq '' or "$destination$url".IO ~~ :e & :f;
            static "$destination", @path, :indexes("$landing\.$ext",);
        }
    }
    my Cro::Service $http = Cro::HTTP::Server.new(
        http => <1.1>,
        :$host, :$port,
        application => $app,
        after => [
            Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
        ]
        );
    say "Serving $landing on $host\:$port" unless %options<no-status>;
    $http.start;
    react {
        whenever signal(SIGINT) {
            say "Shutting down..." unless %options<no-status>;
            $http.stop;
            done;
        }
    }
}
