%(
	:auth<collection>,
	:authors(
		"finanalyst",
	),
	:custom-raku(),
	:license<Artistic-2.0>,
	:name<filtered-toc>,
	:render,
	:template-raku<filtered-toc-template.raku>,
	:jquery(['filtered-toc.js', 2], ),
	:add-css<css/filtered-toc-dark.css css/filtered-toc-light.css>,
	:js-link(
		['src="https://cdn.jsdelivr.net/npm/fuzzysort@2.0.4/fuzzysort.min.js"', 1],
	),
	:information<js-link script>,
	:version<0.1.6>,
)