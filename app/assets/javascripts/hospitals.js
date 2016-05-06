
var showmap = function() {
    $('a[href=#locations]').on('shown.bs.tab', function (e) {
        initialize();
    });
};

function toggle(id) {//hide or shows table content
    if( document.getElementById(id).style.display=='none' ){
        document.getElementById(id).style.display = 'table-row';
        document.getElementById("span" + id).innerHTML = '<i class="fa fa-chevron-up"></i>' + I18n.t('hide');
    }else{
        document.getElementById(id).style.display = 'none';
        document.getElementById("span" + id).innerHTML = '<i class="fa fa-chevron-down"></i>' + I18n.t('show');
    }
}

function ready()
{
    // Open the overview-table by default
    var linkToOverview = document.getElementsByClassName("arrow-span")[0];
    linkToOverview.click();
    showmap();
}


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