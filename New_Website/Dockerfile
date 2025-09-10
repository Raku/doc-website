FROM docker.io/finanalyst/raku-cro-rrr-base AS base

# install deps in stage that does not depend on copy
COPY META6.json .
RUN zef -/test --deps-only install .
RUN mkdir /elucid8
WORKDIR /elucid8
COPY . .
RUN zef install . -/test ;\
    gather-sources;\
    elucid8-build

FROM docker.io/caddy AS server

# docker build --build-arg quay_expiration="8w" -t quay.io/your-repo/your-image:tag .
ARG quay_expiration=never
LABEL quay.expires-after=${quay_expiration}

COPY --from=base /elucid8/publication /website

COPY ./Caddyfile /etc/Caddyfile

CMD caddy run --config /etc/Caddyfile --adapter caddyfile

