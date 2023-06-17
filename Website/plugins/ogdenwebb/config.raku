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
	:version<0.3.18>,
	:css-link(
		'href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/styles/atom-one-light.min.css" title="light"',
		'href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/styles/atom-one-dark.min.css" title="dark"',
	),
	:js-link(
		['src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/highlight.min.js"', 2 ],
		['src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/languages/bash.min.js"', 2 ],
	),
	:add-css<
		css/main.css
		css/themes/dark.css css/themes/light.css
		css/code/dark.css css/code/light.css
	>, # order of css files is important
	:jquery( ['core.js', 3], ),
	:information<add-css jquery css-link js-link>,
);

