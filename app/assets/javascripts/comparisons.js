
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

    // initialize tablesaw for our comparison table
    $("#comparison-table").tablesaw();
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



