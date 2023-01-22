#!/usr/bin/env raku
use v6.d;
# the code is adapted from Liz's runtests routine in Rak.
multi sub MAIN() is export {
    MAIN("OgdenWebb/plugins")
}
multi sub MAIN($path) is export {
    say run(<raku --version>, :out).out.slurp.chomp;
    say "Running on $*DISTRO.gist().\n";

    my @failed;
    my $done = 0;
    my $root = $*CWD;

    sub test-dir($dir) {
        for "$dir/t".IO.dir(:test(*.ends-with: '.t' | '.rakutest')).sort {
            chdir $dir;
            my $fn = .relative;
            say "=== $fn";
            my $proc := run $*EXECUTABLE.absolute, "--ll-exception", "-I$root", $fn, :out, :err, :merge;
            if $proc {
                $proc.out.slurp;
            }
            else {
                @failed.push($_);
                if $proc.out.slurp -> $stdout {
                    my @lines = $stdout.lines;
                    with @lines.first(
                        *.starts-with(" from gen/moar/stage2"), :k)
                    -> $index {
                        say @lines[^$index].join("\n");
                    }
                    else {
                        say $stdout;
                    }
                }
                else {
                    say "No output received, exit-code $proc.exitcode() ($proc.signal())";
                }
            }
            chdir $root;
            $done++;
        }
    }
    for $path.IO.dir(test => /^ \w /).sort {
        say "== $_";
        test-dir($_);
    }
    if @failed {
        say "FAILED: { +@failed } of $done:";
        say "  $_" for @failed;
        exit +@failed;
    }

    say "\nALL { "$done " if $done > 1 }OK";
}