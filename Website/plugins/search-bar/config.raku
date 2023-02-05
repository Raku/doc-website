%(
	:auth<collection>,
	:authors(
		"finanalyst",
	),
	:compilation<add-search.raku>,
	:custom-raku<new-blocks.raku>,
	:transfer<cleanup.raku>,
	:license<Artistic-2.0>,
	:name<search-bar>,
	:render,
	:template-raku<search-templates.raku>,
	:version<0.1.2>,
	:jquery( ['autoComplete.min.js',1], ['search-bar.js',2], ['extended-search.js', 2]),
	:information<jquery jquery-link add-css>,
	:add-css<search-bar.css>,
	:jquery-link(
		['src="https://rawgit.com/farzher/fuzzysort/master/fuzzysort.js"', 1],
		['src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"
			integrity="sha256-VazP97ZCwtekAsvgPBSUwPFKdrwD3unUfSGVYrahUqU="
			crossorigin="anonymous"', 1],
	),
)