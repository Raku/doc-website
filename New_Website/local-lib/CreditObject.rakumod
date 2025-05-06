use v6.d;
use RakuDoc::Render;
use Git::Log;
use JSON::Fast::Hyper;

unit class Raku-Doc-Website::CreditObject;
has %.config =
    :name-space<CreditObject>,
    :version<0.1.0>,
    :license<Artistic-2.0>,
    :credit<finanalyst>,
    :authors<finanalyst>,
    :commit-data( [] ),
    :scss([self.credit-scss,1],),
    get-repo-data => -> %final-config { self.get-repo-data( %final-config ) },
    js-module => [],
    :js-link( ['src="https://unpkg.com/dygraphs@2.2.1/dist/dygraph.min.js"',2], ),
    :css-link( ['href="https://unpkg.com/dygraphs@2.2.1/dist/dygraph.min.css"',1],),
;
method enable( RakuDoc::Processor:D $rdp ) {
    $rdp.add-data( %!config<name-space>, %!config );
    $rdp.add-templates($.credit-templates, :source<CreditObject plugin>)
}
method get-repo-data( %final-config ) {
    my %filter := %final-config<plugin-options><CreditObject><filter>;
    my @change = %filter.keys;
    my @repos = %final-config<repositories>.keys;
    my @repo-data;
    my $repo-dir := %final-config<repository-store>;
    my @fields = [:Name<%an>, :Date<%as>];
    my @periods;
    my $per-year = 2;
    my $n-months = (12 div $per-year) + 1;
    my $start-year = 2009;
    for ^(now.DateTime.year - $start-year + 1) -> $y {
        for ^$per-year -> $per { @periods[$y][$per] = BagHash.new }
    }
    for @repos {
        next if m/'self'/;
        my $path = ($repo-dir ~ '/' ~ ( $_ eq 'self' ?? '.' !! $_ ) ).IO;
        my @res = git-log(:$path,:@fields);
        for @res {
            my $name = .<Name> eq @change.any ?? %filter{ .<Name> } !! .<Name> ;
            my ( $y, $per ) = .year, .month with DateTime.new( .<Date> );
            $y -= $start-year;
            $per = $per div $n-months;
            @periods[ $y ][ $per ]{ $name }++;
        }
    }
    my @objects;
    my SetHash $auths .= new;
    for ^(now.DateTime.year - $start-year + 1) -> $year {
        for ^$per-year -> $per {
            my $bag := @periods[$year][$per];
            my $date = DateTime.new(:year($year + $start-year ),:month( 1 + $per * ($n-months-1) )).yyyy-mm-dd;
            @objects.push: %( :name<Total>, :$date, :commits( [+] $bag.values ) );
             # if a name has occurred in a previous period, add a zero commit to the current period
            for ( $auths.keys (-) $bag.keys ).keys -> $name { @objects.push: %(:$name, :$date, :0commits) }
            for $bag.kv -> $name, $commits {
                @objects.push: %(:$name, :$date, :$commits);
                $auths{ $name }++ # add new names for this period
            }
            @objects.push: %( :name<Others>, :$date, :0commits ); # this is a place holder for each date to be filled later
        }
    }
    #consolidate accross periods
    my %auth-coms;
    @objects.map({ %auth-coms{$_<name>} += $_<commits> });
    # sift out authors with < 10 total commits, and merge them into 'others' for the graph
    $auths .= new; # repurpose auths for others
    %auth-coms.map({ $auths{ .key }++ if .value < 10 });
    $auths<Others>--; #remove Others as a name with less than 10 commits
    my $others = 0;
    # @objects is in order of periods, with 'Others' as last in each period
    @objects = gather for @objects {
        if .<name> eq 'Others' {
            .<commits> = $others; # in period
            %auth-coms<Others> += $others; # overall
            $others = 0;
            take $_
        }
        elsif .<name> (elem) $auths.keys {
            $others += .<commits>
        } # and do not include in stream for diagram
        else { take $_ }
    }
    # trim top and bottom
    @objects.shift until @objects.head<commits>;
    @objects.pop until @objects.tail<commits>;
    %!config<commit-data>.append: %auth-coms
            .sort(*.value)
            .reverse
            .map({ ( .key => .value ).Pair })
            .list;
    my $js-obj = to-json(@objects, :sorted-keys)
            .subst(/ ('"date":') '"' (.+?) '"'/,{ "$0 new Date('$1')" },:g);
    my $js = q:to/JSOBJ/ ~ $js-obj ~ ';' ~ q:to/JSOBJ2/;
    /*----- Generated svg using d3 -----*/
    import * as d3 from "https://cdn.jsdelivr.net/npm/d3@7/+esm";
    var commits =
    JSOBJ
    // Specify the chart’s dimensions.
    const width = 928;
    const height = 600;
    const marginTop = 20;
    const marginRight = 20;
    const marginBottom = 30;
    const marginLeft = 30;

    // Create the positional scales.
    const x = d3.scaleUtc()
        .domain(d3.extent(commits, d => d.date))
        .range([marginLeft, width - marginRight]);

    const y = d3.scaleSymlog()
        .domain([0, d3.max(commits, d => d.commits)]).nice()
        .range([height - marginBottom, marginTop]);

    // Create the SVG container.
    const svg = d3.create("svg")
        .attr("width", width)
        .attr("height", height)
        .attr("viewBox", [0, 0, width, height])
        .attr("style", "max-width: 100%; height: auto; overflow: visible; font: 10px sans-serif;");

    // Add the horizontal axis.
    svg.append("g")
        .attr("transform", `translate(0,${height - marginBottom})`)
        .call(d3.axisBottom(x).ticks(d3.utcMonth.every(6)));

    // Add the vertical axis.
    svg.append("g")
      .attr("transform", `translate(${marginLeft},0)`)
      .call(d3.axisLeft(y).tickValues([0, 1, 3, 10, 30, 100, 300, 1000, 2200]))
      .call(g => g.select(".domain").remove())
      .call(g => g.selectAll(".tick line").clone()
          .attr("x2", width - marginLeft - marginRight)
          .attr("stroke-opacity", 0.1))
      .call(g => g.append("text")
          .attr("x", -marginLeft)
          .attr("y", 10)
          .attr("fill", "currentColor")
          .attr("text-anchor", "start")
          .attr("font-size", "20px")
          .text("Author commits per period"));

    // Compute the points in pixel space as [x, y, z], where z is the name of the series.
    const points = commits.map((d) => [x(d.date), y(d.commits), d.name, d.commits]);

    // Group the points by series.
    const groups = d3.rollup(points, v => Object.assign(v, {z: v[0][2]}), d => d[2]);

    // Draw the lines.
    const line = d3.line();
    const path = svg.append("g")
        .attr("fill", "none")
        .attr("stroke", "steelblue")
        .attr("stroke-width", 1.5)
        .attr("stroke-linejoin", "round")
        .attr("stroke-linecap", "round")
    .selectAll("path")
    .data(groups.values())
    .join("path")
        .attr("d", line);

    // Add an invisible layer for the interactive tip.
    const dot = svg.append("g")
        .attr("display", "none");

    dot.append("circle")
        .attr("r", 2.5);

    dot.append("text")
        .attr("text-anchor", "middle")
        .attr("y", -8);

    svg
        .on("pointerenter", pointerentered)
        .on("pointermove", pointermoved)
        .on("pointerleave", pointerleft)
        .on("touchstart", event => event.preventDefault());

    // When the pointer moves, find the closest point, update the interactive tip, and highlight
    // the corresponding line.
    function pointermoved(event) {
        const [xm, ym] = d3.pointer(event);
        const i = d3.leastIndex(points, ([x, y]) => Math.hypot(x - xm, y - ym));
        const [x, y, k, c] = points[i];
        path.style("stroke", ({z}) => z === k ? null : "#ddd").filter(({z}) => z === k).raise();
        dot.attr("transform", `translate(${x},${y})`);
        dot.select("text").text(k+', '+c);
        svg.property("value", commits[i]).dispatch("input", {bubbles: true});
    }
    function pointerentered() {
        path.style("stroke", "#ddd");
        dot.attr("display", null);
    }
    function pointerleft() {
        path.style("stroke", null);
        dot.attr("display", "none");
        svg.node().value = null;
        svg.dispatch("input", {bubbles: true});
    }
    // Append the SVG element.
    document.addEventListener("DOMContentLoaded", (event) => {
        creditGraph.append(svg.node());
        creditContainer.querySelectorAll('.d3-hilite').forEach( (elem) => {
            elem.addEventListener("mouseenter", (event) => {
                var series = event.currentTarget.innerText;
                path.style("stroke", ({z}) => z === series ? "red" : "lightgrey" ).filter(({z}) => z === series).raise();
            });
            elem.addEventListener("mouseleave", (event) => {
                path.style("stroke", null);
            })
        })
    });
    JSOBJ2
    %!config<js-module>.push: [ $js, 1 ] ;
}
method credit-templates { %(
    CreditObject => -> %prm, $tmpl {
        my @auths := $tmpl.globals.data<CreditObject><commit-data>;
        qq:to/CRDPG/
        <div id="creditContainer" class="section">
            <div id="creditTop" class="buttons">{
                [~] @auths[^10].map({ qq[<button class="d3-hilite button is-info is-light is-small" title="{ .value }">{ .key }</button>] })
            }</div>
            <div id="creditGraph" class="container">\</div>
            <div id="creditRemaining" class="buttons">{
                [~] @auths[10..*].map({ qq[<button class="d3-hilite button is-info is-light is-small" title="{ .value }">{ .key }</button>] })
            }</div>
        </div>
        CRDPG
    },
)}
method credit-scss {
    q:to/SCSS/;
    .d3-hilite:hover {
        background: lightyellow;
    }
    #creditRemaining {
        height: 45vh;
        overflow-y: auto;
    }
    SCSS
}
