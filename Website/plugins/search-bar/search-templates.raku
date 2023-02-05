#!/usr/bin/env raku
use v6.d;
%(
    'head-search' => sub (%prm, %tml) {
        q:to/BLOCK/
            <div class="navbar-end navbar-search-wrapper">
                <div class="navbar-item">
                    <div class="field has-addons">
                        <div id="search" class="control">
                            <input id="query" class="input ui-autocomplete-input" type="text" placeholder="🔍" autocomplete="off">
                        </div>
                        <div class="control">
                            <a class="button is-primary">
                                <span class="icon">
                                    <i class="fas fa-search "></i>
                                </span>
                            </a>
                        </div>
                    </div>
                </div>
                <div id="navbar-search" class="navbar-search-autocomplete" style="display: none;">
                    <ul id="ui-id-1" tabindex="0" class="ui-menu ui-widget ui-widget-content ui-autocomplete ui-front" style="display: none;"></ul>
                </div>
            </div>
	    BLOCK
   },
    extendedsearch => sub (%prm, %tml) {
        return q:to/ERROR/ without %prm<extendedsearch>;
            <div class="listf-error">ExtendedSearch has no collected data,
            is ｢extendedsearch｣ in the Mode's ｢plugins-required<compilation>｣ list?
            </div>
            ERROR
        qq:to/SEARCH/;
          <div class="container px-4">
            <div class="search-form mb-4">
              <div class="field">
                <div class="control has-icons-right">
                  <input id="search-input" class="input" type="text" placeholder="Search">
                  <span class="icon is-small is-right">
                    <i class="fas fa-search"></i>
                  </span>
                </div>
              </div>
              <nav class="level">
                <!-- Left side -->
                <div class="level-left">
                  <div class="level-item">
                    <div class="field">
                      <div class="control">
                        <div class="select">
                          <select id="search-category-select">
                            <option value="All">All</option>
                            { %prm<extendedsearch>.map(
                                { '<option value="' ~ $_ ~ '">' ~ $_ ~ '</option>' }
                            ) }
                          </select>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="level-right">
                  <div class="level-item">
                    <div id="search-count" class="raku search-result-amount">Type in a Search string</div>
                  </div>
                </div>
              </nav>
            </div>
            <div class="raku-search results"></div>
          </div>
        <script defer="" src="/assets/scripts/js/extended-search.js"></script>
        SEARCH
    },
);