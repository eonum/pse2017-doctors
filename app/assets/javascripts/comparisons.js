//= require swipetooltip

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

    $(document).on('click', '.hopmodal', function () {
        console.log($(this).attr('data-modalhref'));
        var $hopModal = $('#hop-modal');
        $hopModal.removeData("bs.modal").find(".modal-content").empty();
        $hopModal.modal({
            show: true,
            remote: $(this).attr('data-modalhref')
        });
    });

    var $table = $("#comparison-table");

    // initialize tablesaw for our comparison table
    $table.tablesaw();

    addSwipeTooltip();
};

$(document).ready(ready);
$(document).on('page:load', ready);

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
$(document).ready(colourButtons);
$(window).resize(colourButtons);
function colourButtons(){
    var $buttons = $(".btn-info");
    var rowLength;
    if($(window).width() >= 1200)
        rowLength = 4;
    else if($(window).width() >= 645)
        rowLength = 2;
    else
        rowLength = 1;

    $buttons.each(function (i) {
        var row = Math.floor(i / rowLength);
        var rowIndex = i - (row*rowLength);
        if(row % 2 === 0) {
            if (rowIndex % 2 === 0) {
                $(this).css('background-color', '#E0E0E0');
            }
            else
                $(this).css('background-color', 'white');
        }
        else {
            if (rowIndex % 2 === 1) {
                $(this).css('background-color', '#E0E0E0');
            }
            else
                $(this).css('background-color', 'white');
        }
    });
}


