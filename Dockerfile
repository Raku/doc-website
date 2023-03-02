FROM docker.io/caddy:latest 
buildah add $c raku-doc-website.tar.gz /usr/share/caddy
buildah add $c Caddyfile /etc/caddy/Caddyfile
buildah commit --rm $c quay.io/colemanx/raku-doc-website:latest
buildah push quay.io/colemanx/raku-doc-website:latest
