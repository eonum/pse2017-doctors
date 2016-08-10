
var showmap = function() {
    $('a[href=#locations]').on('shown.bs.tab', function (e) {
        initialize();
    });
};

var ready = function() {
    showmap();
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

    var chart = new google.visualization.AreaChart(document.getElementById('time_series_' + time_series.id));
    chart.draw(data, options);
};