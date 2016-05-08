var swipeTooltipShown = false;
var ready = function() {
    $(".orange-highlight").animate({backgroundColor: 'rgb(250, 234, 120)'}, 2500);
    if (typeof numcase_data != "undefined") {
        Object.keys(numcase_data).forEach(function (id) {
            $(id).animate({width: numcase_data[id] + '%'}, 2500);
        })
    }

    $(".cantons").removeClass("highlight", 150);
    var canton = getUrlParameter('canton');
    if (canton != undefined) {
        $("#canton-" + canton).addClass("highlight", 250);
    }

    $(document).on('click', '.hopmodal', function() {
        console.log($(this).attr('data-modalhref'));
        var $hopModal = $('#hop-modal');
        $hopModal.removeData("bs.modal").find(".modal-content").empty();
        $hopModal.modal({
            show: true,
            remote: $(this).attr('data-modalhref')
        });
    });

    var $table = $("#comparison-table")
    // initialize tablesaw for our comparison table
    $table.tablesaw();

    // creates the swipeinfo once, only on mobile devices
    var tableExists = $table !== undefined;
    if(!swipeTooltipShown && isMobile && tableExists)
    {
        swipeInfo();
        swipeTooltipShown = true;
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);

/*$(document).on("hidden.bs.modal", '#hop-modal', function (e) {
    $(e.target).removeData("bs.modal").find(".modal-content").empty();
});*/


$( function() {
    var change_comparison = function() {
        var comparison_url = $('#comparison').find(":selected").val();
        Turbolinks.visit(comparison_url + '?location=' + app.location, { change: ['main-content'] });
    };

    $(document).on('change', '#comparison-selection-form button a, #comparison-selection-form select', change_comparison);
});


var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};

function isMobile() {
    return ('ontouchstart' in document.documentElement);
}


function swipeInfo() {
    var swipeinfo = $("#swipeinfo"),
        table = $("#comparison-table"),
        tableHead = $("#comparison-head"),
        mainContent = $("#main-content"),
        floating = true,
        fixedPosition = $(window).height()/2;
        swipeinfo.css({
            'top': fixedPosition,
            'margin-left': -(table.offset().left+swipeinfo.width())
        });


    function timeShiftedShow(){
        setTimeout(function () {
            var lastColumnShown = tableHead.find('th').not(".tablesaw-ignore").last().is(":visible");

            if(lastColumnShown){
                swipeinfo.remove();
                return;
            }

            toggleFloating();
            swipeinfo.fadeTo(400, 1.0);
        }, 3000);
    }

    function toggleFloating() {
        var scrollAreaTop = $(window).scrollTop() + fixedPosition;
        var correction = mainContent.offset().top;
        var tableHeaderEnd = tableHead.offset().top + tableHead.height();
        if (scrollAreaTop <= tableHeaderEnd && floating) {
            swipeinfo.css({
                'position': 'absolute',
                'top': tableHeaderEnd - correction,
                'margin-left': -(swipeinfo.width()+15)
            });
            floating = false;
        }
        if (scrollAreaTop >= tableHeaderEnd && !floating) {
            swipeinfo.css({
                'position': 'fixed',
                'top': fixedPosition,
                'margin-left': -(table.offset().left+swipeinfo.width())
            });
            floating = true;
        }
    }

    function bindEvents() {
        $(window).scroll(toggleFloating);

        swipeinfo.click(function () {
            $(this).fadeOut("slow", function () {
                $(this).remove();
            });
        });

        //pass touchevents to the table
        swipeinfo.on('touchstart touchmove touchend', function (event) {
            table.trigger(event);
        });

        // remove the hint if advancing the table was discovered
        table.on('tablesaw-advance tablesaw-all-visible', function () {
            swipeinfo.remove();
        });
    }

    timeShiftedShow();
    bindEvents();
}



