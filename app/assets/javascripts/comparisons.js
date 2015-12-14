
var ready = function() {
    $(".orange-highlight").animate({backgroundColor: 'rgb(250, 234, 120)'}, 2500);
    if (typeof numcase_data != "undefined") {
        Object.keys(numcase_data).forEach(function (id) {
            $(id).animate({width: numcase_data[id] + '%'}, 2500);
        })
    }
};

$(document).ready(ready);
$(document).on('page:load', ready)


$( function() {
    $(document).on('change', '#comparison-selection-form button, select', function() {
        var comparison_url = $('#comparison').find(":selected").val();
        // TODO get location and submit
        Turbolinks.visit(comparison_url, { change: ['main-content'] });
    });

    $(document).on('click', '.time-series', function() {
        var field_name = $(this).closest('td').attr("data-fieldname");
        var hopid = $(this).closest('tr').attr("data-hopid");
        // Is there a way of using a rails url helper here.
        $.getJSON('../hospitals/' + hopid + '/field?field_name=' + field_name, function(data) {
            $('#field-info-box').html(data.response['2013']);
        })
    });
});



/*

function updateComparison(comparison) {
    var container =  $('#main-content');
    container.empty();
    container.append($('<h2>').append(comparison.name));
    container.append($('<p>').append(comparison.description));

    var table = $('<table>');
    table.addClass('table table-striped');
    var header = $('<thead>');
    var row = '<tr>';
    row += '<th>';
    row += I18n.t('institution');
    row += '<h5><small>' + I18n.t('institution-description') + '</small></h5>';
    row += '</th>';
    for(var i in comparison.variables) {
        var variable = comparison.variables[i];
        row += '<th>';
        row += variable.name;
        row += '<h5><small>' + variable.description + '</small></h5>';
        row += '</th>';
    }
    row += '</tr>';
    header.append(row);
    table.append(header);

    var body = $('<tbody>');
    for(var hi in comparison.hospitals) {
        var h = comparison.hospitals[hi];
        body += '<tr><td>';
        body += '<a href="' + h.url + '">' + h.name + '</a>'
        body += '<h6><small>' + h.address2 + '</small></h6></td>';
        for(var i in comparison.variables) {
            var variable = comparison.variables[i];
            body += '<td>';
            var value = h[variable.field_name];
            if(variable.is_time_series && value != null) {
                value = value[comparison.base_year];
            }
            if(value != null)
                body += value;
            body += '</td>';
        }
        body += '</tr>';
    }

    table.append(body);
    container.append(table);
}*/
