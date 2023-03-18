# Raku Documentation
>The Collection files for the Raku Documentation site.


## Table of Contents
[Installation](#installation)  
[Building the documentation locally](#building-the-documentation-locally)  
[Building the Development mode](#building-the-development-mode)  
[Options for build-site](#options-for-build-site)  
[Directory naming](#directory-naming)  
[Plugins and Templates](#plugins-and-templates)  
[Running site](#running-site)  
[Working on Collection plugins](#working-on-collection-plugins)  

----
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
Two 'Modes' are contained in the distribution under their own directories:

*  **Website** This is the production mode used to build `docs.raku.org`

*  **Development** This is the development mode, used to test functionality of UX before being adopted for **Website**. If a developer wishes to propose changes, they should first be made to **Development**.

Generic build steps:

*  clone this repo to `raku-doc-website/`

	*  No need to clone the Raku documentation sources at `github.com/raku/doc/doc` to `local_raku_docs/doc/` as this is done automatically by the final step. However, if you already have a local `raku/doc` repo, then change the relevant key in `config.raku`. It should be intuitive what is required.

	*  Note also the `'_'` character in the default directory name. This is important for Collection if the document sources are under the `raku-doc-website` because Collection treats directories without `'_'` as `mode` directories.

*  assume that the **Website** mode is being built. The default mode (Website) is given as a key in `doc-website/config.raku`.

	*  assume the rendered html will be built in `rendered_html`

All these names can be changed by changing the relevant parts of the config.raku file

Now run

```
bin_files/build-site
```
If Cro and Cro::HTTP have been installed, then `build-site` will automatically launch a Cro app and the whole website will be served on `localhost:30000`.

## Building the Development mode
Run

```
bin_files/build-site Development
```
The whole website will be served as before on `localhost:30000`

The html will be generated in `development_rendered_html`

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

# Plugins and Templates
Collection is designed to handle multiple Modes, and for plugins to be contributed in a similar way to Raku Modules. However, for the Raku documentation system, it seems pragmatic at the start for the plugins to be tailored specifically for this site.

Consequently, the plugins are directly copied into the OgdenWebb directory, rather than using Collection's `refresh` functionality. This comment may seem odd but I include it to preclude questions that will arise when reading the documentation for `Collection`.

The Templates were originally developed to mimic **Moritz Lenz's** Raku site (the one we are used to). Relevant template keys are modified in the `ogdenwebb` plugin. I would expect this to change over time, and for the default templates to change to the OgdenWebb templates. But I would suggest this is done incrementally.

# Running site
Whilst this repo is being developed, a running on-line site can be found at [new-raku](https://new-raku.finanalyst.org).

# Working on Collection plugins
Collection uses plugins - they can be found under the directory `Website/plugins/ ` - which contain both callables that set up templates, associate CSS (defined using SCSS) with classes etc, and manipulate data.

Whilst the best way to work on the plugins is, as described below, to use the dedicated plugins distribution, it increases the learning curve and also means that there is an extra step in directly importing Collection plugins to the Raku Documentation repo (as mentioned above, the 'refresh' functionality of Collection is not used here).

However, to make development here easier, there are three utilities which directly affect this distribution:

*  `update-css` which is a Bash file and takes the name of a plugin as its argument.

	*  This expects the Node.js version of `sass` to be installed in your path.

	*  Installation instructions can be found [here](https://sass-lang.com/install).

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







----
Rendered from README at 2023-03-18T09:07:43Z