#!/bin/sh

c=$(buildah from docker.io/nginx:1.23.3-alpine)
buildah add $c raku-doc-website.tar.gz /usr/share/nginx/html
buildah commit --rm $c quay.io/colemanx/raku-doc-website:latest
buildah push quay.io/colemanx/raku-doc-website:latest

