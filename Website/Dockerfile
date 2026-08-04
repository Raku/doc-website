FROM docker.io/raku-doc-website-base AS builder
RUN apk add --no-cache zip

WORKDIR /build
COPY . .

# Install dependencies and build site
RUN ./bin_files/build-site --without-completion --no-status
RUN ./bin_files/build-site --no-status EBook

FROM docker.io/caddy:latest AS server

ARG quay_expiration=never
LABEL quay.expires-after=${quay_expiration}

COPY --from=builder /build/rendered_html /usr/share/caddy
COPY ./Caddyfile /etc/Caddyfile

CMD caddy run --config /etc/Caddyfile --adapter caddyfile
