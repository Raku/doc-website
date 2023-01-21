# Raku Documentation
>The Collection files for the Raku Documentation site.


## Table of Contents
[Installation](#installation)  
[Building the documentation locally](#building-the-documentation-locally)  
[Directory naming](#directory-naming)  
[Plugins and Templates](#plugins-and-templates)  
[Running site](#running-site)  

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

*  clone the Raku documentation sources at `github.com/raku/doc/doc` to `local_raku_docs/doc/`

	*  Note that local_raku_docs could be simply a clone of `github.com/raku/doc`

	*  Note also the '_' character in the directory name. This is important for Collection but should not matter here as there is only one 'Mode' (see Collection documentation for more information on modes)

*  assume the rendered html will be built in `rendered_html`

All these names can be changed by changing the relevant parts of the config.raku file

Now run

```
bin_files/build-site
```
# Directory naming
As mentioned in the items above, Collection expects a sub-directory that does not include a '_' in its name to be a 'Mode'.

For this reason, documentation sources for this repo are in `repo_docs` and the binaries are in `bin_files`.

This may prove unnecessary.

However, I think there should be another Mode in this repository in due course that generates an epub output.

# Plugins and Templates
Collection is designed to handle multiple Modes, and for plugins to be contributed in a similar way to Raku Modules. However, for the Raku documentation system, it seems pragmatic at the start for the plugins to be tailored specifically for this site.

Consequently, the plugins are directly copied into the OgdenWebb directory, rather than use the refresh functionality. This comment may seem odd but I include it to preclude questions that will arise when reading the documentation for `Collection`.

The Templates were originally developed to mimic Moritz Lenz's Raku site. Relevant template keys are modified in the `ogdenwebb` plugin. I would expect this to change over time.

# Running site
Whilst this repo is being developed, a running on-line site can be found at [new-raku](https://new-raku.finanalyst.org).







----
Rendered from README at 2023-01-21T01:09:19Z