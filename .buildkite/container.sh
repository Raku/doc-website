#!/bin/sh

set -eu

image_tag=$1
version_tag="v1-$(date +%Y%m%d)-${BUILDKITE_BUILD_NUMBER}"

c=$(buildah from docker.io/caddy:latest)
buildah add $c raku-doc-website.tar.gz /usr/share/caddy
buildah add $c Caddyfile /etc/caddy/Caddyfile

# Commit with latest tag
buildah commit --rm $c quay.io/colemanx/raku-doc-website:latest

# Create a new container for the versioned tag with expiration label
c2=$(buildah from quay.io/colemanx/raku-doc-website:latest)
buildah config --label quay_expiration=8w $c2
buildah commit --rm $c2 quay.io/colemanx/raku-doc-website:$version_tag

# Push both tags
buildah push quay.io/colemanx/raku-doc-website:latest
buildah push quay.io/colemanx/raku-doc-website:$version_tag

