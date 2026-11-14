#!/usr/bin/env raku
#
# Compare languages in ui-dictionary.rakuon with the reference language (en)
#
# Usage:
#       raku check-ui-dictionary.raku [lang ...]  (no lang = check all)
#
# Exit code is 1 when any key is missing, extra or empty.
#

constant $ref-lang = 'en';

sub MAIN(*@langs)
{
    my %dict = $*PROGRAM.parent.add('ui-dictionary.rakuon').slurp.EVAL;
    unless %dict{$ref-lang}:exists {
        note "Reference language '$ref-lang' not found.";
        exit 2;
    }
    if @langs.grep({ !(%dict{$_}:exists) }) -> @unknown {
        note "Unknown language(s): {@unknown}. Available: {%dict.keys.sort}";
        exit 2;
    }
    my $ref-keys = %dict{$ref-lang}.keys.Set;
    my $problems = 0;

    for (@langs || %dict.keys.sort).grep(* ne $ref-lang) -> $lang {
        my $keys    = %dict{$lang}.keys.Set;
        my @missing = ($ref-keys (-) $keys).keys.sort;
        my @extra   = ($keys (-) $ref-keys).keys.sort;
        my @empty   = %dict{$lang}.grep({ .value !~~ Str || .value.trim eq '' }).map(*.key).sort;
        $problems += @missing + @extra + @empty;

        say "[$lang] {$keys.elems}/{$ref-keys.elems} keys (ref-lang: $ref-lang)";
        say "  missing: $_" for @missing;
        say "  extra (not in $ref-lang): $_" for @extra;
        say "  empty/non-string: $_" for @empty;
    }

    say $problems ?? "\n$problems problem(s) found." !! "\nNo problems found.";
    exit($problems ?? 1 !! 0);
}
