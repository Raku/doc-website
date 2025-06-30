FROM docker.io/finanalyst/raku-cro-rrr-base
# Registry-specific metadata to not store every
# build indefinately
ARG quay_expiration
LABEL quay.expires-after=${quay_expiration}


# install deps in stage that does not depend on copy
RUN zef install Elucid8::Build -/test

# remove unneeded dependents
RUN apk del gcc linux-headers make musl-dev perl
RUN addgroup -S appgroup && adduser -S rakoon -G appgroup

RUN mkdir /elucid8
WORKDIR /elucid8

USER rakoon
CMD zef install . -/test; gather-sources; elucid8-build
