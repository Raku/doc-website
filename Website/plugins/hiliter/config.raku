%(
	:auth<collection>,
	:authors(
		"finanalyst",
	),
	:custom-raku(),
	:license<Artistic-2.0>,
	:name<hiliter>,
	:render,
	:template-raku<template.raku>,
	:version<0.1.5>,
	:css-link(
		'href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/styles/atom-one-light.min.css" title="light"',
		'href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/styles/atom-one-dark.min.css" title="dark"',
	),
	:js-link(
		['src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/highlight.min.js"', 2 ],
		['src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/languages/haskell.min.js"', 2 ],
	),
	:add-css<hiliter-dark.css hiliter-light.css>,
	:jquery( ['hiliter.js', 4], ),
	:information<css-link js-link jquery>,
)