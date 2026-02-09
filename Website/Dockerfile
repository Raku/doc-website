FROM docker.io/finanalyst/raku-cro-rrr-base AS builder

WORKDIR /build
COPY . .

# Install dependencies and build site
RUN POD_RENDER_NO_HIGHLIGHTER=1 zef install . --deps-only
RUN ./bin_files/build-site --without-completion --no-status

FROM docker.io/caddy:latest AS server

ARG quay_expiration=never
LABEL quay.expires-after=${quay_expiration}

COPY --from=builder /build/rendered_html /usr/share/caddy
COPY ./Caddyfile /etc/Caddyfile

CMD caddy run --config /etc/Caddyfile --adapter caddyfile
