# install elucid8-build from git
FROM docker.io/finanalyst/raku-cro-rrr-base AS base
RUN git clone https://github.com/elucid8-org/build.git builder
WORKDIR /builder
RUN zef install .

RUN mkdir /elucid8
COPY . /elucid8
WORKDIR /elucid8
RUN zef install .
RUN gather-sources
RUN elucid8-build

FROM docker.io/caddy AS server

# docker build --build-arg quay_expiration="8w" -t quay.io/your-repo/your-image:tag .
ARG quay_expiration=never
LABEL quay.expires-after=${quay_expiration}

COPY --from=base /elucid8/publication /website

COPY ./Caddyfile /etc/Caddyfile

CMD caddy run --config /etc/Caddyfile --adapter caddyfile

