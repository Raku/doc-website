%(
	:auth<collection>,
	:authors(
		"finanalyst",
		"ogdenwebb",
		"altai-man",
	),
	:custom-raku(),
	:license<Artistic-2.0>,
	:name<ogdenwebb>,
	:render<move-images.raku>,
	:template-raku<ogdenwebb-replacements.raku>,
	:error-report,
	:!extended-search,
	:version<0.3.8>,
	:add-css<
		css/main.css
		css/themes/dark.css css/themes/light.css
		css/code/dark.css css/code/light.css
	>, # order of css files is important
	:jquery( ['core.js', 3], ),
	:information<add-css jquery>,
)