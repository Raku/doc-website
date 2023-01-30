#!/bin/sh
(
  cd rendered_html
  sh -c 'tar zcf ../raku-doc-website.tar.gz *'
)
