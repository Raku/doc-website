# Raku Documentation
>The Collection files for the Raku Documentation site.


## Table of Contents
[Installation](#installation)  
[Building the documentation locally](#building-the-documentation-locally)  
[Options for build-site](#options-for-build-site)  
[Directory naming](#directory-naming)  
[Deprecated URLs](#deprecated-urls)  
[Plugins and Templates](#plugins-and-templates)  
[Working on Collection plugins](#working-on-collection-plugins)  
[Deployment of website](#deployment-of-website)  

----
(The README.md version is generated from `repo_docs/README.rakdoc`)

# Installation
The assumption for this README is that the OS is a version of Linux, or that anyone wanting to attempt this knows their own OS well enough to understand the differences.

This repo can be cloned and the main dependencies can be installed with

```
zef install . --deps-only
```
in the cloned directory. There are a couple of C libraries that may need to be installed as well, such as OpenSSL and LibArchive (make sure to install the ``-dev`` versions).

Cro is needed for serving the rendered files locally. You may wish to install it separately.

Syntax highlighting of Raku code in the documentation still requires a ``node.js`` stack. See the documentation for ``Raku::Pod::Render`` for more information.

# Building the documentation locally
Generic build steps:

*  clone this repo to `raku-doc-website/`

	*  No need to clone the Raku documentation sources at `github.com/raku/doc/doc` to `local_raku_docs/doc/` as this is done automatically by the final step. However, if you already have a local `raku/doc` repo, then change the relevant key in `config.raku`. It should be intuitive what is required.

	*  Note also the `'_'` character in the default directory name. This is important for Collection if the document sources are under the `raku-doc-website` because Collection treats directories without `'_'` as `mode` directories.

*  assume the rendered html will be built in `rendered_html`

All these names can be changed by changing the relevant parts of the config.raku file

Now run

```
bin_files/build-site
```
If Cro and Cro::HTTP have been installed, then `build-site` will automatically launch a Cro app and the whole website will be served on `localhost:30000`.

# Options for `build-site`
There are many options for build-site, which is a thin wrapper around the `collect` sub in `Collection`.

However, you can run

```
bin_files/build-site --help
```
or

```
bin_files/build-site --more-help
```
for a quick overview.

# Directory naming
As mentioned in the items above, Collection expects a sub-directory that does not include a `'_'` in its name to be a 'Mode'.

For this reason, documentation sources for this repo are in `repo_docs` and the binaries are in `bin_files`.

This may eventually prove unnecessary, but it is a reasonable convention is kept for the time being.

Further, in the future, another Mode may be useful in this repository in due course that generates an epub output.

# Deprecated URLs
Occasionally, file names change. This would cause a 404 error if an external webpage, e.g. someone's blog, has a link to a changed file name. To overcome this, a mapping file `deprecated-urls` is kept in `Website/plugins/raku-doc-setup`. The plugin adds this file to ``rendered_html/assets/``, and the Caddy system rewrites routes from the deprecated name to the working alternative.

# Plugins and Templates
Collection is designed to handle multiple Modes, and for plugins to be contributed in a similar way to Raku Modules. However, for the Raku documentation system, it seems pragmatic at the start for the plugins to be tailored specifically for this site.

Consequently, the plugins are directly copied into the OgdenWebb directory, rather than using Collection's `refresh` functionality. This comment may seem odd but I include it to preclude questions that will arise when reading the documentation for `Collection`.

The Templates were originally developed to mimic **Moritz Lenz's** Raku site (the one we are used to). Relevant template keys are modified in the `ogdenwebb` plugin. I would expect this to change over time, and for the default templates to change to the OgdenWebb templates. But I would suggest this is done incrementally.

# Working on Collection plugins
Collection uses plugins - they can be found under the directory `Website/plugins/ ` - which contain both callables that set up templates, associate CSS (defined using SCSS) with classes etc, and manipulate data.

Whilst the best way to work on the plugins is, as described below, to use the dedicated plugins distribution, it increases the learning curve and also means that there is an extra step in directly importing Collection plugins to the Raku Documentation repo (as mentioned above, the 'refresh' functionality of Collection is not used here).

However, to make development here easier, there are three utilities which directly affect this distribution:

*  `update-css` which is a Bash file and takes the name of a plugin as its argument.

*  `bin_files/test-all-plugins` This runs all the test files in all the plugins

*  `bin_files/build-site` By default this will

	*  refresh the documents from the contents repository at github/raku/docs

	*  cache any changes to the source documents

	*  render all the source documents

However, if a change to a plugin has been made and it can be seen with only one or two source files, then it is quicker to use the `build-site` option `with-only`, eg

```
bin_files/build-site --with-only='language.rakudoc operators'
```
There is a file in `Website/structure-sources/language.rakudoc` and a file in the doc sources called `doc/language/operators.pod6`. Any element in the space delimited list following `--with-only` that matches a source file name will be rendered.

A better way, though, to tweak or add new plugins and see how they affect the website, is to install the distribution `raku-collection-plugin-development`.

# Deployment of website
The Production version of the website is at `docs.raku.org`. A regularly updated version is at `docs-dev.raku.org`.

Here's how deployment works right now:

After a PR to the doc-website repository is reviewed, it's merged to `main` The very fact that it is a merge to main is important metadata for the CI pipeline. See also the Buildkite docs on using conditionals in pipeline steps.

What this means in practice is that the container is only built if the changes are happening on main:

*  A merge to main from a PR

*  A periodic scheduled build against main (every two hours);

	*  We need this one so we can pick up content changes from the other repo.

*  The Raku scripts clone Raku/doc as a part of their build process.

Here is how the container build works:

*  We start from a caddy base image

*  The tarball of generated static source code is downloaded from Buildkite's temporary storage

*  This tarball is added and unarchived inside the container

*  The "Caddyfile" at the root of this repo is also added

*  The container is "committed", tagged, and pushed to the quay.io container registry

	*  The tag that we use is quay.io/colemanx/raku-doc-website:latest

	*  The fact that we are overwriting "latest" every two hours on a periodic build can be seen [here](https://quay.io/repository/colemanx/raku-doc-website?tab=history)

*  Completely independent of this process is a cron job running on the dev server. This job simply pulls the latest container image and swaps out what's running. If this is working properly, the website at `https://docs-dev.raku.org` is updated at most every two hours with the latest content, and the latest changes from this repo.

Deployment to Production is similar, but not automatic. The site maintainer activates an agent running on the production server that pulls the latest container image and swaps out what's running.







----
Rendered from README at 2023-09-10T19:18:22Z