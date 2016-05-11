
var showmap = function() {
    $('a[href=#locations]').on('shown.bs.tab', function (e) {
        initialize();
    });
};

//hide or shows table content
function toggle(id) {
    var comparison = $("#"+id),
        comparisonSwitch = $("#"+"span" + id);

    if( comparison.css( "display" ) === "none" ){
        comparison.show();
        comparisonSwitch.html('<i class="fa fa-chevron-up"></i>' + I18n.t('hide'));
    }
    else {
        comparison.hide();
        comparisonSwitch.html('<i class="fa fa-chevron-down"></i>' + I18n.t('show'));
    }
}

var ready = function() {
    showmap();
    // Open the overview-table by default
    var linkToOverview = $(".arrow-span")[0];
    if(linkToOverview !== undefined)
        linkToOverview.click();
};


$(document).ready(ready);
$(document).on('page:load', ready);

var visualize_time_series_small = function visualize_time_series_small(time_series) {
    var data_array = [];
    data_array.push([I18n.t('year'), time_series.var_name]);
    Object.keys(time_series.response).forEach(function (year) {
        var value = parseFloat(time_series.response[year]);
        data_array.push([year, value]);
    });

    var data = google.visualization.arrayToDataTable(data_array);

    var options = {
        height: 100,
        width: 180,
        legend: {position: 'none'}
    };

    var chart = new google.visualization.AreaChart(document.getElementById('time_series_' + time_series.field_name));
    chart.draw(data, options);
};