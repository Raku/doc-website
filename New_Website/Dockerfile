FROM docker.io/finanalyst/raku-cro-rrr-base AS base

# install deps in stage that does not depend on copy
RUN zef install -/test "Elucid8::Build" "Git::Log" "JSON::Fast::Hyper"
RUN mkdir /elucid8
WORKDIR /elucid8
COPY . .
RUN zef install . -/test;\
     gather-sources;\
     elucid8-build;

FROM docker.io/caddy AS server

COPY --from=base /elucid8/publication /website

COPY ./Caddyfile /etc/Caddyfile

CMD caddy run --config /etc/Caddyfile --adapter caddyfile