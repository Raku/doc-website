# must be generated from parent directory
FROM docker.io/finanalyst/raku-cro-rrr-base AS base

RUN mkdir /elucid8
COPY New_Website /elucid8
COPY .git .git
WORKDIR /elucid8
RUN zef install --deps-only -/test .
RUN zef install .
RUN gather-sources
RUN elucid8-build

# FROM docker.io/caddy AS server
#
# # docker build --build-arg quay_expiration="8w" -t quay.io/your-repo/your-image:tag .
# ARG quay_expiration=never
# LABEL quay.expires-after=${quay_expiration}
#
# COPY --from=base /elucid8/publication /website
#
# COPY ./Caddyfile /etc/Caddyfile
#
# CMD caddy run --config /etc/Caddyfile --adapter caddyfile
#
