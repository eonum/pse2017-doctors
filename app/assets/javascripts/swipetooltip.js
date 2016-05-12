var swipeTooltipShown = false;

function isMobile() {
    return ('ontouchstart' in document.documentElement);
}

/*
 * Adds a swipe tooltip to the table, which floats at the right
 * end of the table, until the user clicks on it or advances in the table
 * Does nothing  if the tooltip is not required (see shouldShowTooltip)
 */
function addSwipeTooltip() {
    var $swipeTooltip,
        $table = $("#comparison-table"),
        $tableHead = $("#comparison-head"),
        $mainContent = $("#main-content"),
        fixedPosition = $(window).height()/2;

    /*
     * Decides (returns true) if the swipe tooltip should be shown
     * The tooltip is shown only once, on the first tablesaw-table the users sees and only
     * if he can swipe to advance in the table
     */
    function shouldShowTooltip(){
        var lastColumnShown = $tableHead.find('th').not(".tablesaw-ignore").last().is(":visible"),
            tableExists = $table.length !== 0;
        return (!swipeTooltipShown && isMobile() && tableExists && !lastColumnShown)
    }

    function init(){
        $swipeTooltip = $("<div>"+I18n.t('swipetooltip')+"</div>").addClass("swipe-tooltip");
        var $image = $("<img src='/assets/tactile-left-movement.png' />");
        $swipeTooltip.append($image);
        $table.append($swipeTooltip);

        $swipeTooltip.css({
            'top': fixedPosition,
            'margin-left': -($table.offset().left+$swipeTooltip.width())
        });

        timeShiftedShow();
        bindEvents();

        swipeTooltipShown = true;
    }

    function timeShiftedShow(){
        setTimeout(function () {
            toggleFloating();
            $swipeTooltip.fadeTo(400, 1.0);
        }, 3000);
    }

    function toggleFloating() {
        var tooltipTop = $(window).scrollTop() + fixedPosition,
            tableHeaderBottom = $tableHead.offset().top + $tableHead.height();

        if (tooltipTop <= tableHeaderBottom) {
            if ($swipeTooltip.css('position') !== 'absolute') {
                // position absolute for the tooltip is measured from the maincontent top, not the document top
                var correction = $mainContent.offset().top;
                $swipeTooltip.css({
                    'position': 'absolute',
                    'top': tableHeaderBottom - correction,
                    'margin-left': -($swipeTooltip.width()+15)
                });
            }
        }
        else if ($swipeTooltip.css('position') !== 'fixed') {
            $swipeTooltip.css({
                'position': 'fixed',
                'top': fixedPosition,
                'margin-left': -($table.offset().left+$swipeTooltip.width())
            });
        }
    }

    function vanish(){
        $swipeTooltip.fadeOut("slow", function () {
            $swipeTooltip.remove();
        });
    }

    function bindEvents() {
        $(window).scroll(toggleFloating);

        $swipeTooltip.click(vanish);

        // remove the tooltip if advancing the table was discovered
        $table.on('tablesaw-advance tablesaw-all-visible', vanish);
    }

    if(shouldShowTooltip())
        init();
}