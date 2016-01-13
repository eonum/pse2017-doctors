
var showmap = function() {
    $('a[href=#locations]').on('shown.bs.tab', function (e) {
        initialize();
    });
}

$(document).ready(showmap);
$(document).on('page:load', showmap)