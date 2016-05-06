/*! Tablesaw - v2.0.2 - 2015-10-28
* https://github.com/filamentgroup/tablesaw
* Copyright (c) 2015 Filament Group; Licensed  */
/*
* tablesaw: A set of plugins for responsive tables
* Stack and Column Toggle tables
* Copyright (c) 2013 Filament Group, Inc.
* MIT License
/*
 * modified in 2016 by pf15ese for qualimed-hospitals
 * Do not replace with newer tablesaw version to keep changes:
 * Improved swipe tables and added a fixed header
 * stack and column toggle tables as well as the sort feature
 * are no longer supported
 * New Usage: $(#mytableid).tablesaw();
 * this automatically creates all features, the swipetable,
 * the fixed header and the column-minimap
 */

if( typeof Tablesaw === "undefined" ) {
	Tablesaw = {
		i18n: {
			columns: 'Col<span class=\"a11y-sm\">umn</span>s',
			columnBtnText: 'Columns',
			columnsDialogError: 'No eligible columns.',
		},
		// cut the mustard
		mustard: 'querySelector' in document &&
			( !window.blackberry || window.WebKitPoint ) &&
			!window.operamini
	};
}
if( !Tablesaw.config ) {
	Tablesaw.config = {};
}
if( Tablesaw.mustard ) {
	jQuery( document.documentElement ).addClass( 'tablesaw-enhanced' );
}

(function( $ ) {
	var pluginName = "tablesaw",
		classes = {
			toolbar: "tablesaw-bar",
			unimportantCell: "tablesaw-ignore",
			toolbarMainCell: "tablesaw-tool-cell",
			toolbarFillCell: "tablesaw-fill-cell"
		},
		events = {
			create: "tablesawcreate",
			destroy: "tablesawdestroy",
			refresh: "tablesawrefresh"
		};

	var Table = function( element ) {
		if( !element ) {
			throw new Error( "Tablesaw requires an element." );
		}

		this.table = element;
		this.$table = $( element );

		this.init();
	};

	Table.prototype.init = function() {
		// assign an id if there is none
		if ( !this.$table.attr( "id" ) ) {
			this.$table.attr( "id", pluginName + "-" + Math.round( Math.random() * 10000 ) );
		}

		this.createToolbar();

		var colstart = this._initCells();
		// initialize all sub-plugin in the right order
		this.$table[ "tablesaw-swipetable" ]();
		this.$table[ "tablesaw-minimap" ]();
		this.$table[ "tablesaw-fixedheader" ]();

		this.$table.trigger( events.create, [ this, colstart ] );
	};

	Table.prototype._initCells = function() {
		var colstart,
			thrs = this.table.querySelectorAll( "thead tr" ),
			self = this;

		$( thrs ).each( function(){
			var coltally = 0;

			$( this ).children().each( function(){
				var span = parseInt( this.getAttribute( "colspan" ), 10 ),
					sel = ":nth-child(" + ( coltally + 1 ) + ")";

				colstart = coltally + 1;

				if( span ){
					for( var k = 0; k < span - 1; k++ ){
						coltally++;
						sel += ", :nth-child(" + ( coltally + 1 ) + ")";
					}
				}

				// Store "cells" data on header as a reference to all cells in the same column as this TH
				this.cells = self.$table.find("tr").not( thrs[0] ).not( this ).children().filter( sel );
				coltally++;
			});
		});

		return colstart;
	};

	Table.prototype.refresh = function() {
		this._initCells();

		this.$table.trigger( events.refresh );
	};

	Table.prototype.createToolbar = function() {
		// Insert the toolbar
		var $toolbar = this.$table.find('*').filter( '.' + classes.toolbar );
		if( !$toolbar.length ) {
			$toolbar = $( '<tr>' )
				.addClass( classes.toolbar );
		}

		this.$table.find("thead").prepend($toolbar);
		var $filler = $('<th colspan=\"1\">').addClass(classes.unimportantCell)
					.addClass(classes.toolbarFillCell);
		$toolbar.append($filler);
		var $toolCell = $('<th colspan=\"2\">').addClass(classes.unimportantCell)
						.addClass(classes.toolbarMainCell);
		$toolbar.append($toolCell);

	};

	Table.prototype.destroy = function() {
		// Don’t remove the toolbar. Some of the table features are not yet destroy-friendly.
		this.$table.find('*').filter( '.' + classes.toolbar ).each(function() {
			this.className = this.className.replace( /\bmode\-\w*\b/gi, '' );
		});

		var tableId = this.$table.attr( 'id' );
		$( document ).unbind( "." + tableId );
		$( window ).unbind( "." + tableId );

		// other plugins
		this.$table.trigger( events.destroy, [ this ] );

		this.$table.removeData( pluginName );
	};

	// Collection method.
	$.fn[ pluginName ] = function() {
		return this.each( function() {
			var $t = $( this );

			if( $t.data( pluginName ) ){
				return;
			}

			var table = new Table( this );
			$t.data( pluginName, table );
		});
	};

}( jQuery ));

(function( win, $, undefined ){
	var pluginName = "tablesaw-swipetable";

	$.extend( Tablesaw.config, {
		swipe: {
			horizontalThreshold: 45,
			verticalThreshold: 22
		}
	});

	function isIE8() {
		var div = document.createElement('div'),
			all = div.getElementsByTagName('i');

		div.innerHTML = '<!--[if lte IE 8]><i></i><![endif]-->';

		return !!all.length;
	}

	function SwipeTable( $table ){
		var $btns = $( "<div class='tablesaw-advance'></div>" ),
			$prevBtn = $( "<a href='#' class='tablesaw-nav-btn btn btn-micro left' title='Previous Column'></a>" ).appendTo( $btns ),
			$nextBtn = $( "<a href='#' class='tablesaw-nav-btn btn btn-micro right' title='Next Column'></a>" ).appendTo( $btns ),
			hideBtn = 'disabled',
			$headerCells = $table.find( "thead th").not(".tablesaw-ignore"),
			$headerCellsNoPersist = $headerCells.not( '[data-tablesaw-priority="persist"]' ),
			$toolbarFiller = $($table.find( "thead th").filter(".tablesaw-fill-cell")),
			decreasingHeaderWidths = [],
			tableId = $table.attr( 'id' ),
			// Should the table go back to the beginnig/the end when continue moving at an edge?
			// Default (without the attribute NoWrap) is true
			wrapped = $table.attr('NoWrap')=== undefined,
			persistentCount = $headerCells.length - $headerCellsNoPersist.length,
			visibleNonPersistentCount;

		function init() {
			// Calculate initial widths
			$table.css('width', 'auto');
			$headerCells.each(function () {
				decreasingHeaderWidths.push($(this).outerWidth());
			});

			decreasingHeaderWidths.sort(function (a, b) {
				return b - a;
			});

			$table.css('width', '');

			$btns.appendTo($table.find('*').filter('.tablesaw-tool-cell'));

			$table.addClass("tablesaw-swipe");

			if (!tableId) {
				tableId = 'tableswipe-' + Math.round(Math.random() * 10000);
				$table.attr('id', tableId);
			}

			$prevBtn.add( $nextBtn ).click(function( e ){
				advance( !!$( e.target ).closest( $nextBtn ).length );
				e.preventDefault();
			});

			fakeBreakpoints();
			bindAllEvents();
		}

		function $getCells( headerCell ) {
			return $( headerCell.cells ).add( headerCell );
		}

		function showColumn( headerCell ) {
			$getCells( headerCell ).removeClass( 'tablesaw-cell-hidden' );
		}

		function hideColumn( headerCell ) {
			$getCells( headerCell ).addClass( 'tablesaw-cell-hidden' );
		}

		function persistColumn( headerCell ) {
			$getCells( headerCell ).addClass( 'tablesaw-cell-persist' );
		}

		/**
		 * Returns the index of the first visible column (from the left to the right)
		 *
		 * @returns {Number} the index of the first visible column
		 * or 0 if we didn't find any visible column
		 */
		function getFirstVisibleColumn(){
			for(i = 0; i < $headerCellsNoPersist.length; i++)
			{
				var $column = $( $headerCellsNoPersist.get( i )),
					isHidden = $column.css( "display" ) === "none" || $column.is( ".tablesaw-cell-hidden" );

				if( !isHidden ) {
					return i;
				}
			}
			return 0;
		}

		/**
		 * Returns the index of the last visible column (as seen from the left to the right)
		 *
		 * @returns {Number} the index of the last visible column
		 * or -1 if there is no visible column
		 */
		function getLastVisibleColumn(){
			return getFirstVisibleColumn()+visibleNonPersistentCount-1;
		}

		/**
		 * Returns pairwise (hidden/shown) the columns that should change visibility when moving in one direction
		 * inside the table. This always returns as many column-pairs as we can possibly move in one direction,
		 * without skipping any column. If we reached an edge and the table is wrapped this will return as much column-pairs
		 * from the beginning/the end as we currently see.
		 *
		 * @param {Boolean} forward - indicates in which direction the shown columns should change
		 * 							  true means forward (to the right), false means back (to the left)
		 * @returns {Array} An array of columns-pairs ($headerCellsNoPersist), the first part of the pair is
		 * the column that should get hidden and the second one the column that should be shown instead.
		 */
		function changingColumnPairs( forward ){
			var offset = forward ? 1 : -1,
				// we must either begin after the last visible column or before the first visible column
				firstInvisibleColumn = forward ? getLastVisibleColumn() + 1 : getFirstVisibleColumn() - 1,
				nextHiddenShownColumnPairs = [],
				mustWrap = !inTable(firstInvisibleColumn) && wrapped;

			// add column-pairs as long as we don't reach a border of the array or changed all visible columns
			for(i = firstInvisibleColumn; (mustWrap || inTable(i)) && nextHiddenShownColumnPairs.length <  visibleNonPersistentCount; i+=offset)
			{
				var nextPair = [];
				// first add the column that should get hidden to the pair
				// we begin to hide from the last visible column in the opposite direction
				nextPair.push($headerCellsNoPersist.get( ( i + (offset * -1 * visibleNonPersistentCount)) %$headerCellsNoPersist.length) );
				// add the column that should be shown
				nextPair.push($headerCellsNoPersist.get( i % $headerCellsNoPersist.length ));
				nextHiddenShownColumnPairs.push(nextPair);
			}

			return nextHiddenShownColumnPairs;
		}

		function inTable( columnIndex ){
			return columnIndex >= 0 && columnIndex < $headerCellsNoPersist.length;
		}

		function canAdvance( forward ){
			return wrapped || (forward ? inTable(getLastVisibleColumn()+1)  : inTable(getFirstVisibleColumn() -1));
		}

		function canAdvanceForward(){
			return canAdvance( true );
		}

		function canAdvanceBackward(){
			return canAdvance( false );
		}

		function matchesMedia() {
			var matchMedia = $table.attr( "data-tablesaw-swipe-media" );
			return !matchMedia || ( "matchMedia" in win ) && win.matchMedia( matchMedia ).matches;
		}

		function fakeBreakpoints() {
			if( !matchesMedia() ) {
				return;
			}

			var containerWidth = $table.parent().width()+1, //+1 to cope with rounding errors
				persist = [],
				headerWidthsSum = 0,
				partialHeaderWidthsSums = [];
				visibleNonPersistentCount = $headerCells.length;

			$headerCells.each(function( index ) {
				var $t = $( this ),
					isPersist = $t.is( '[data-tablesaw-priority="persist"]' );

				persist.push( isPersist );

				// sum up beginning with the widest column, because while advancing
				// the worst case (needing the most place) that still should fit is that
				// all n visible columns are as wide as the n widest columns
				headerWidthsSum += decreasingHeaderWidths[ index ];
				partialHeaderWidthsSums.push( headerWidthsSum );

				// is persistent or is hidden
				if( isPersist || headerWidthsSum > containerWidth ) {
					visibleNonPersistentCount--;
				}
			});

			var needsNonPersistentColumn = visibleNonPersistentCount === 0;

			$headerCells.each(function( index ) {
				if( persist[ index ] ) {
					persistColumn( this );
					return;
				}

				if( partialHeaderWidthsSums[ index ] <= containerWidth || needsNonPersistentColumn ) {
					// set the visibleNonPersistentCount correctly if we force to show a column
					if(needsNonPersistentColumn) {
						visibleNonPersistentCount = 1;
						needsNonPersistentColumn = false;
					}
					showColumn( this );
				} else {
					hideColumn( this );
				}
			});

			adaptToolbar();

			$table.trigger( 'tablesawcolumns' );
			$table.trigger( 'tablesaw-resize' );
		}

		/**
		 * Corrects the position of the toolbar-tools (minimap,buttons) when
		 * the number of shown columns change.
		 */
		function adaptToolbar(){
			// 2 is the size of the maincell with the tools inside
			var cellsToFill = visibleNonPersistentCount + persistentCount - 2;

			if(cellsToFill > 0) {
				//extend the filler to push the tools to the left end
				$toolbarFiller.attr("colspan", cellsToFill);
				$toolbarFiller.show();
			}
			else 			// if cellsToFill = 0
				$toolbarFiller.hide();
		}

		/**
		 * Advances through the table by showing new columns and hiding the columns that were visible before.
		 * Always advances as many columns as possible without skipping any. If an edge is reached and the table is wrapped,
		 * the visible columns will be taken from the other edge. The number of visible columns always stays the same, persistent
		 * columns never get hidden.
		 * @param {Boolean} forward - indicates in which direction the shown columns should change
		 * 							  true means forward (to the right), false means back (to the left)
		 */
		function advance( fwd ){
			var shownHiddenPairs = changingColumnPairs( fwd );
			if( canAdvance(fwd) ){

				shownHiddenPairs.forEach(function (shownHiddenPair){
					hideColumn( shownHiddenPair[ 0 ]  );
					showColumn( shownHiddenPair[ 1 ]  );
				});

				$table.trigger( 'tablesawcolumns' );
				$table.trigger( 'tablesaw-advance' );
			}
		}

		// See advance
		function advanceForward(){
			return advance( true );
		}

		// See advance
		function advanceBackward(){
			return advance( false );
		}

		function getCoord( event, key ) {
			return ( event.touches || event.originalEvent.touches )[ 0 ][ key ];
		}

		function bindAllEvents() {
			$( win ).on( "resize", fakeBreakpoints );

			//Fixes wrong restoring when using turbolinks
			$( win ).on( "page:restore", fakeBreakpoints );

			$table
				.bind("touchstart.swipetoggle", function (e) {
					var originX = getCoord(e, 'pageX'),
						originY = getCoord(e, 'pageY')+$(win).scrollTop(),
						x,
						y;

					$(win).off("resize", fakeBreakpoints);

					$(this)
						.bind("touchmove", function (e) {
							x = getCoord(e, 'pageX');
							y = getCoord(e, 'pageY')+$(win).scrollTop();
							var cfg = Tablesaw.config.swipe;
							if (Math.abs(x - originX) > cfg.horizontalThreshold && Math.abs(y - originY) < cfg.verticalThreshold) {
								e.preventDefault();
							}
						})
						.bind("touchend.swipetoggle", function () {
							var cfg = Tablesaw.config.swipe;
							if (Math.abs(y - originY) < cfg.verticalThreshold) {
								if (x - originX < -1 * cfg.horizontalThreshold) {
									advanceForward();
								}
								if (x - originX > cfg.horizontalThreshold) {
									advanceBackward();
								}
							}

							window.setTimeout(function () {
								$(win).on("resize", fakeBreakpoints);
							}, 300);
							$(this).unbind("touchmove touchend");
						});

				})
				.bind("tablesawcolumns.swipetoggle", function () {
					$prevBtn[canAdvanceBackward() ? "removeClass" : "addClass"](hideBtn);
					$nextBtn[canAdvanceForward() ? "removeClass" : "addClass"](hideBtn);
				})
				.bind("tablesawnext.swipetoggle", function () {
					advanceForward();
				})
				.bind("tablesawprev.swipetoggle", function () {
					advanceBackward();
				})
				.bind("tablesawdestroy.swipetoggle", function () {
					var $t = $(this);

					$t.removeClass('tablesaw-swipe');
					$t.find('*').filter('.tablesaw-bar').find('.tablesaw-advance').remove();
					$(win).off("resize", fakeBreakpoints);

					$t.unbind(".swipetoggle");
				});
		}

		init();
	}

	/**
	 * Creates this plugin, do not use separately as the tablesaw
	 * main plugin takes care of creating the other plugins in
	 * the right order
	 */
	$.fn[ pluginName ] = function() {
		return this.each( function() {
			var $t = $( this );

			if( $t.data( pluginName ) ){
				return;
			}

			var table = new SwipeTable( $(this) );
			$t.data( pluginName, table );
		});
	};

}( this, jQuery ));

(function( win, $, undefined ){
	var pluginName = "tablesaw-minimap";

	var MM = {
		attr: {
			init: 'data-tablesaw-minimap'
		}
	};

	function MiniMap( $table ){

		var $btns = $( '<div class="tablesaw-advance minimap">' ),
			$dotNav = $( '<ul class="tablesaw-advance-dots">' ).appendTo( $btns ),
			hideDot = 'tablesaw-advance-dots-hide',
			$headerCells = $table.find( 'thead th').not(".tablesaw-ignore");
		function init() {
			// populate dots
			$headerCells.each(function () {
				$dotNav.append('<li><i></i></li>');
			});

			$btns.appendTo($table.find('*').filter('.tablesaw-tool-cell'));

			// run on init and resize
			showHideNav();
			$( win ).on( "resize", showHideNav );


			$table
				.bind( "tablesawcolumns.minimap", function(){
					showHideNav();
				})
				.bind( "tablesawdestroy.minimap", function(){
					var $t = $( this );

					$t.find('*').filter( '.tablesaw-bar' ).find( '.tablesaw-advance' ).remove();
					$( win ).off( "resize", showHideNav );

					$t.unbind( ".minimap" );
				});
		}
		function showMinimap( $table ) {
			var mq = $table.attr( MM.attr.init );
			return !mq || win.matchMedia && win.matchMedia( mq ).matches;
		}

		function showHideNav(){
			if( !showMinimap( $table ) ) {
				$btns.hide();
				return;
			}
			$btns.show();

			// show/hide dots
			var dots = $dotNav.find( "li" ).removeClass( hideDot );
			$headerCells.each(function(i){
				if( $( this ).css( "display" ) === "none" ){
					dots.eq( i ).addClass( hideDot );
				}
			});
		}

		init();
	}

	/**
	 * Creates this plugin, do not use separately as the tablesaw
	 * main plugin takes care of creating the other plugins in
	 * the right order
	 */
	$.fn[ pluginName ] = function() {
		return this.each( function() {
			var $t = $( this );

			if( $t.data( pluginName ) ){
				return;
			}

			var table = new MiniMap( $(this) );
			$t.data( pluginName, table );
		});
	};


}( this, jQuery ));

/**
 * A subplugin of tablesaw to add fixed table headers
 */
(function integratedFixedHeader( win, $, undefined ){
	var pluginName = "tablesaw-fixedheader";

	/**
	 * Adds a fixed table header to the table,that scrolls along with the page.
	 */
	function FixedHeader( $table ){
		var floatingHeader,
			floatingHeaderCells,
			originalTable = $table,
			originalHeader =  $table.find("thead:first"),
			originalHeaderCells = originalHeader.find('th');

		function init(){
			createFloatingHeader();

			$( window ).scroll( function() {
				toggleFloating();
			});

			// recreate the floatingHeader if the originalHeader changes
			originalTable.on('tablesaw-resize',function()
			{
				createFloatingHeader();
			});

			originalTable.on('tablesaw-advance',function()
			{
				createFloatingHeader();
			});
		}

		/**
		 * (Re-)creates the floating header to copy all styles and recent changes of them
		 * from the original header
		 */
		function createFloatingHeader(){
			var oldFloatingHeader = floatingHeader;

			floatingHeader = originalHeader.clone();

			floatingHeader.css({
				'position': 'fixed',
				'top': 0,
			});
			floatingHeaderCells = floatingHeader.find('th');

			bindButtons();
			copyOriginalHeaderWidths();
			toggleFloating();

			originalTable.append(floatingHeader);

			if(oldFloatingHeader !== undefined)
				oldFloatingHeader.remove();
		}

		/**
		 * Binds the original button events on the copied buttons as well
		 */
		function bindButtons(){
			var rightButton = floatingHeader.find('.right');

			rightButton.click(function( event ){
				originalTable.trigger("tablesawnext.swipetoggle");
				event.preventDefault();
			});

			var leftButton = floatingHeader.find('.left');
			leftButton.click(function( event ){
				originalTable.trigger("tablesawprev.swipetoggle");
				event.preventDefault();
			});
		}

		/**
		 * Defines all widths on the copied header to be the same as on the original header
		 * otherwise the browser would take care of the widths on the copied header
		 */
		function copyOriginalHeaderWidths(){
			floatingHeaderCells.each(function( index ) {
				$(this).css({'width': $(originalHeaderCells[index]).outerWidth(),
					'display': $(originalHeaderCells[index]).css('display')});
			});

			floatingHeader.css({
				'width': originalHeader.outerWidth()
			});
		}

		/**
		 * Shows or hides the floating header, depending on how much the window is scrolled
		 */
		function toggleFloating() {
			var scrolled = $(win).scrollTop(),
				headerOffset = originalHeader.offset().top,
				scrolledPastHeader = scrolled > headerOffset;
			if (scrolledPastHeader)
				floatingHeader.show();
			else
				floatingHeader.hide();
		}

		init();
	}

	/**
	 * Creates this plugin, do not use separately as the tablesaw
	 * main plugin takes care of creating the other plugins in
	 * the right order
	 */
	$.fn[ pluginName ] = function() {
		return this.each( function() {
			var $t = $( this );

			if( $t.data( pluginName ) ){
				return;
			}

			var table = new FixedHeader( $(this) );
			$t.data( pluginName, table );
		});
	};

}( this, jQuery ));

