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
	:js-script<filtered-toc.js>,
	:add-css<css/filtered-toc-dark.css css/filtered-toc-light.css>,
	:jquery-link(
		['src="https://rawgit.com/farzher/fuzzysort/master/fuzzysort.js"', 1],
	),
	:information<jquery-link>,
	:version<0.1.2>,
)