
var ready = function() {
    $(".orange-highlight").animate({backgroundColor: 'rgb(250, 234, 120)'}, 2500);
    if (typeof numcase_data != "undefined") {
        Object.keys(numcase_data).forEach(function (id) {
            $(id).animate({width: numcase_data[id] + '%'}, 2500);
        })
    }


    $('.time-series').prop('title', I18n.t('show_time_series'));
    $(document).on('click', '.time-series', function () {
        var varid = $(this).closest('td').attr("data-varid");
        var hopid = $(this).closest('tr').attr("data-hopid");
        // Is there a way of using a rails url helper here?
        $.getJSON('../hospitals/' + hopid + '/field?varid=' + varid,  visualize_time_series)
    });

    $(".cantons").removeClass("highlight", 150);
    var canton = getUrlParameter('canton');
    if (canton != undefined) {
        $("#canton-" + canton).addClass("highlight", 250);
    }

    $(document).on('click', '.hopmodal', function() {
        console.log($(this).attr('data-modalhref'));
        $('#hop-modal').removeData("bs.modal").find(".modal-content").empty();
        $('#hop-modal').modal({
            show: true,
            remote: $(this).attr('data-modalhref')
        });
    });
};

$(document).ready(ready);
$(document).on('page:load', ready)

/*$(document).on("hidden.bs.modal", '#hop-modal', function (e) {
    $(e.target).removeData("bs.modal").find(".modal-content").empty();
});*/


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

var visualize_time_series = function visualize_time_series(time_series) {
    var data_array = [];
    data_array.push([I18n.t('year'), time_series.var_name]);
    Object.keys(time_series.response).forEach(function (year) {
        var value = parseFloat(time_series.response[year]);
        data_array.push([year, value]);
    })

    var data = google.visualization.arrayToDataTable(data_array);

    var options = {
        title: time_series.hop_name,
        hAxis: {title: I18n.t('year'),  titleTextStyle: {color: '#333'}},
        legend: {position: 'top'}
    };

    var chart = new google.visualization.AreaChart(document.getElementById('field-info-box'));
    chart.draw(data, options);
}