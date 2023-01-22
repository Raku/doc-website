%(
	:auth<collection>,
	:authors(
		"finanalyst",
		"ogdenwebb",
		"altai-man",
	),
	:custom-raku<new-blocks.raku>,
	:license<Artistic-2.0>,
	:name<ogdenwebb>,
	:render<move-images.raku>,
	:compilation<add-search.raku>,
	:transfer<cleanup.raku>,
	:template-raku<ogdenwebb-replacements.raku>,
	:version<0.1.14>,
	:add-css<
		css/main.css
		css/themes/dark.css css/themes/light.css
		css/code/dark.css css/code/light.css
	>, # order of files is important
	# css/lib/codemirror.min.css
	:jquery(
		['js/core.js', 3],
		['js/search.js', 4],
		['js/lib/autoComplete.min.js', 1],
		['js/lib/cookie.umd.min.js', 1],
	),
	#		js/extended-search.js
	#		js/lib/codemirror.min.js
	#	js/lib/raku-mode.js
	:jquery-link(
		['src="https://rawgit.com/farzher/fuzzysort/master/fuzzysort.js"', 1],
		['src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"
			integrity="sha256-VazP97ZCwtekAsvgPBSUwPFKdrwD3unUfSGVYrahUqU="
			crossorigin="anonymous"', 1],
		['src="https://use.fontawesome.com/releases/v5.3.1/js/all.js"', 2],
	),
	:information<add-css jquery jquery-link>,
)