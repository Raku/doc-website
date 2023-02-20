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
    my $app = route {
        get -> *@path {
            static "$destination", @path,:indexes( "$landing\.$ext", );
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
    say "Serving $landing on http://$host\:$port" unless %options<no-status>;
    $http.start;
    react {
        whenever signal(SIGINT) {
            say "Shutting down..." unless %options<no-status>;
            $http.stop;
            done;
        }
    }
}
