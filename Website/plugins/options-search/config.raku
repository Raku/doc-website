%(
	:auth<collection>,
	:authors(
		"finanalyst",
		"rawleyfowler"
	),
	:compilation<add-options-search.raku>,
	:custom-raku(),
	:transfer<cleanup.raku>,
	:license<Artistic-2.0>,
	:name<options-search>,
	:render,
	:template-raku<options-search-templates.raku>,
	:version<0.1.13>,
	:information<css-link>,
	:add-css<css/options-search-light.css css/options-search-dark.css>,
	:js-link(
		['src="https://cdn.jsdelivr.net/npm/@tarekraafat/autocomplete.js@10.2.7/dist/autoComplete.min.js"', 1],
	),
	:js-script( ['options-search.js',2], ),
	:css-link<href="https://cdn.jsdelivr.net/npm/@tarekraafat/autocomplete.js@10.2.7/dist/css/autoComplete.min.css">,
)