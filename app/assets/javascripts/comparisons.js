
var ready = function() {
    $(".orange-highlight").animate({backgroundColor: 'rgb(250, 234, 120)'}, 2500);
    if (typeof numcase_data != "undefined") {
        Object.keys(numcase_data).forEach(function (id) {
            $(id).animate({width: numcase_data[id] + '%'}, 2500);
        })
    }


    $('.time-series').prop('title', I18n.t('show_time_series'));
    $(document).on('click', '.time-series', function () {
        var field_name = $(this).closest('td').attr("data-fieldname");
        var hopid = $(this).closest('tr').attr("data-hopid");
        // Is there a way of using a rails url helper here?
        $.getJSON('../hospitals/' + hopid + '/field?field_name=' + field_name, function (data) {
            // TODO visualize
            $('#field-info-box').html(JSON.stringify(data.response));
        })
    });

    $(".cantons").removeClass("highlight", 150);
    var canton = getUrlParameter('canton');
    if (canton != undefined) {
        $("#canton-" + canton).addClass("highlight", 250);
    }
};

$(document).ready(ready);
$(document).on('page:load', ready)


$( function() {
    var change_comparison = function() {
        var comparison_url = $('#comparison').find(":selected").val();
        Turbolinks.visit(comparison_url + '?location=' + app.location, { change: ['main-content'] });
    }

    $(document).on('change', '#comparison-selection-form button a, select', change_comparison);
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