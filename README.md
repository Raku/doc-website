# Raku Documentation
>The Collection files for the Raku Documentation site.


## Table of Contents
[Installation](#installation)  
[Building the documentation locally](#building-the-documentation-locally)  
[Directory naming](#directory-naming)  
[Plugins and Templates](#plugins-and-templates)  
[Running site](#running-site)  
[Working on Collection plugins](#working-on-collection-plugins)  

----
# Installation
A fully automatic installation process needs information about the location of the Rakudoc (aka POD6) sources and where the rendered html files are to be built.

This README is for the first commit, so it is assumed experienced Raku users will be using it for the time being.

When the website is to be built automatically, there will be no need to serve it locally so the completion plugin will not be a Cro App, but a transfer process.

The META6.json has most of the dependencies, but NOT Cro, which has been found to fail in automatic testing environments. It is best to install Cro directly.

Installing Raku::Pod::Render can be done without the highlighter. But to build the site with highlighted raku code requires (for the time being) `npm`.

So zef install . --deps-only

in the cloned directory should work.

# Building the documentation locally
Generic build steps:

*  clone this repo to `raku-doc-website/`

	*  No need to clone the Raku documentation sources at `github.com/raku/doc/doc` to `local_raku_docs/doc/` as this is done automatically by the final step. However, if you already have a local `raku/doc` repo, then change the relevant key in `config.raku`. It should be intuitive what is required.

	*  Note also the '_' character in the default directory name. This is important for Collection if the document sources are under the `raku-doc-website` because Collection treats directories without '_' as `mode` directories.

*  assume the rendered html will be built in `rendered_html`

All these names can be changed by changing the relevant parts of the config.raku file

Now run

```
bin_files/build-site
```
# Directory naming
As mentioned in the items above, Collection expects a sub-directory that does not include a '_' in its name to be a 'Mode'.

For this reason, documentation sources for this repo are in `repo_docs` and the binaries are in `bin_files`.

This may eventually prove unnecessary, but I suggest the convention is kept for the time being.

Futher, I think there should be another Mode in this repository in due course that generates an epub output.

# Plugins and Templates
Collection is designed to handle multiple Modes, and for plugins to be contributed in a similar way to Raku Modules. However, for the Raku documentation system, it seems pragmatic at the start for the plugins to be tailored specifically for this site.

Consequently, the plugins are directly copied into the OgdenWebb directory, rather than using Collection's `refresh` functionality. This comment may seem odd but I include it to preclude questions that will arise when reading the documentation for `Collection`.

The Templates were originally developed to mimic **Moritz Lenz's** Raku site (the one we are used to). Relevant template keys are modified in the `ogdenwebb` plugin. I would expect this to change over time, and for the default templates to change to the OgdenWebb templates. But I would suggest this is done incrementally.

# Running site
Whilst this repo is being developed, a running on-line site can be found at [new-raku](https://new-raku.finanalyst.org).

# Working on Collection plugins
Collection uses plugins - they can be found under the directory `OdgenWebb/plugins/ ` - which contain both callables that set up templates, associate CSS (defined using SCSS) with classes etc, and manipulate data.

The best way, at present, to tweak plugins and see how they affect the website, is to install the distribution `raku-collection-plugin-development`. The plugin SCSS (for example) can be changed, then updated into CSS using `./update-css <plugin-name> `. The plugins can be tested using `test-all-collection-plugins`. This utility runs each of the tests under the plugin directories.

(All Collection plugins must adhere to some rules that include having a README.rakudoc file, a `t/` directory, and various other keys, as defined in the Collection documentation). Collection is being designed to run multiple Collections, each of which may use different plugins, and that new plugins can be developed as alternatives for existing plugins, but with greater functionality. In addition, a developer can retain an older version of a plugin for a specific collection if a newer version breaks a website. This implements a <version>.<improvement>.<patch> versionning system for all plugins.

The effect of a tweaked plugin on the website can be tested using `run-collection-trial OgdenWebb`. The trial subdirectory has a (very) few Rakudoc (aka POD6) files from the raku/doc rep. The Rakudoc sources include the most troublesome. The new website is then served to `localhost:5000`.

If there is a problem with one source, then use

```
run-collection-trial --with-only='language.rakudoc other-source and-so-on' OgdenWebb
```
Collection will then only render files that match one of the elements in the space-delimited list provided with `--with-only`. 'language.rakudoc' is a useful index file to link to other files.

There are a bunch of other options to help debugging, and they can be found in the Collection documentation.







----
Rendered from README at 2023-01-21T15:32:07Z