FROM docker.io/finanalyst/raku-cro-rrr-base AS base
RUN zef install Elucid8::Run-locally
RUN mkdir /elucid8
COPY . /elucid8
WORKDIR /elucid8
RUN zef install .
RUN gather-sources
RUN elucid8-build
CMD run-locally

