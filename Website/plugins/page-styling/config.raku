%(
	:auth<collection>,
	:authors(
		"finanalyst"
	),
	:custom-raku(),
	:license<Artistic-2.0>,
	:name<page-styling>,
	:render<move-images.raku>,
	:template-raku<page-styling.raku>,
	:version<0.3.3>,
	:add-css<
		css/page-styling-main.css
		css/page-styling-dark.css css/page-styling-light.css
		css/chyronToggle-dark.css css/chyronToggle-light.css
		css/centreToggle-dark.css css/centreToggle-light.css
	>, # order of css files is important
	:jquery( ['page-styling.js', 3], ),
	:information<add-css jquery>,
)