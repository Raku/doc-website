# Getting this to work

Obtain an image by running Podman using DockerFile.

Run a container based on the image with volume 
setting `New_Website` directory in repo to `/elucid8` in container.

The following directories are created:
- publication - which contains the HTML for the website.
- repo - which contain clones of three Github repos:
  - rakudoc - The current Rakudoc specification
  - raku-doc - The raku documentation repo
  - for-testing - the finanalyt/tmp-test repo

Next steps:
- containerise it with a script like
```
cd publication
sh -c 'tar zcf ../new_website.tar.gz *'
c=$(buildah from docker.io/caddy:latest)
buildah add $c ../new-website.tar.gz /usr/share/caddy
buildah add $c ../Caddyfile /etc/caddy/Caddyfile

buildah commit --rm $c <image name>
rm ../new_website.tar.gz
```
