# Getting this to work

Install Elucid8-build.
```
    zef install Elucid8-build
```

In the New_Website directory run:
1. `gather-sources`
  - After this, a directory `repos` will appear, and a file under `misc`.
2. `raku -I. elucid8-build`

The `-I.` is needed to ensure the plugins in `local-libs`
are compiled.

Once `elucid8-build` has completed, a new directory is 
created (`publication`), which contains the whole website.

The config file `configs/01-base.raku` has `with-ony` field. This limits
the files to be rendered to a few. Setting `:with-only()` will render
all the sources in the repos.

This can be containerised with
```
#!/bin/sh
if [ -z "$1" ]; then
  echo -e "There must be a target directory"
  exit 1
fi
if [ -L "$1" ]; then
  echo -e "$1 is a link. It must be a real directory."
  exit 1
fi
if ! [ -d "$1" ]; then
  echo -e "$1 is not a directory."
  exit 1
fi
cd $1
sh -c 'tar zcf ../new_raku.tar.gz *'
c=$(buildah from docker.io/caddy:latest)
buildah add $c ../new_website.tar.gz /usr/share/caddy
buildah add $c ../Caddyfile /etc/caddy/Caddyfile

buildah commit --rm [ name of container ]
rm ../new_website.tar.gz
echo '=== completed image'
```
