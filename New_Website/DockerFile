FROM alpine:latest

ENV PATH="/usr/share/perl6/site/bin:$PATH"

ARG rakudo=main

# Leave git installed for zef.
RUN apk add --no-cache gcc git linux-headers make musl-dev perl graphviz
RUN git clone -b $rakudo https://github.com/rakudo/rakudo       \
 && cd rakudo                                                   \
 && CFLAGS=-flto ./Configure.pl                                 \
    --gen-moar                                                  \
    --moar-option=--ar=gcc-ar                                   \
    --prefix=/usr                                               \
 && make install                                                \
 && strip /usr/lib/libmoar.so                                   \
 && cd /                                                        \
 && rm -rf rakudo

ARG getopt=0.4.2
ARG prove6=0.0.17
ARG tap=0.3.14
ARG zef=v0.22.7

RUN git clone -b $zef https://github.com/ugexe/zef        \
 && perl6 -Izef/lib zef/bin/zef --/test install ./zef     \
    $([ -z $getopt ] || echo "Getopt::Long:ver<$getopt>") \
    $([ -z $prove6 ] || echo "App::Prove6:ver<$prove6>" ) \
    $([ -z $tap    ] || echo "TAP:ver<$tap>"            ) \
 && rm -rf zef

# install a SASS compiler
ARG DART_SASS_VERSION=1.82.0
ARG DART_SASS_TAR=dart-sass-${DART_SASS_VERSION}-linux-x64-musl.tar.gz
ARG DART_SASS_URL=https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/${DART_SASS_TAR}
ADD ${DART_SASS_URL} /opt/
RUN cd /opt/ && tar -xzf ${DART_SASS_TAR} && rm ${DART_SASS_TAR}
RUN ln -s /opt/dart-sass/sass /usr/local/bin/sass

# install deps in stage that does not depend on copy
RUN zef install Rakuast::RakuDoc::Render Elucid8::Build

# remove unneeded dependents
RUN apk del gcc linux-headers make musl-dev perl

RUN mkdir /elucid8
WORKDIR /elucid8
CMD zef install . -/test; gather-sources; elucid8-build
