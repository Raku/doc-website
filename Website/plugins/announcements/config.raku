%(
	:auth<collection>,
	:authors(
		"finanalyst",
	),
	:add-css<css/announce-light.css css/announce-dark.css>,
	:license<Artistic-2.0>,
	:name<announcements>,
	:render<namespace-setup.raku>,
	:template-raku<anouncement-templates.raku>,
	:custom-raku<announcement-blocks.raku>,
	:transfer<generate-javascript.raku>,
	:version<0.1.1>,
	:information<js-script>,
	:js-script(['announcements.js', 4],),
)