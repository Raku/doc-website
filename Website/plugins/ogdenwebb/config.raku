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
	:version<0.2.13>,
	:add-css<
		css/main.css
		css/themes/dark.css css/themes/light.css
		css/code/dark.css css/code/light.css
	>, # order of files is important
	# css/lib/codemirror.min.css
	:jquery( ['core.js', 3], ),
	:information<add-css jquery>,
)