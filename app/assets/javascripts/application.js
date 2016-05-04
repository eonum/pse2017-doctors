// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.cookie
//= require jquery-ui/autocomplete
//= require jquery-ui/effect.all
//= require jquery-ui/sortable
//= require twitter/bootstrap
//= require turbolinks
//= require nprogress
//= require nprogress-turbolinks
//= require turboboost
//= require gmaps
//= require tagmanager
//= require i18n
//= require i18n/translations
//= require tablesaw
//= require_tree .

// creates all tooltips in the navbar, as soon as the site gets or is bigger than 768px (changes from mobile to desktop version)
// in the mobile-view the tooltips would get created at the wrong place
$(document).ready(function() {
    var toggleTooltip = function () {
        var width = $(window).width();
        var mobileNavbarThreshold = 768;
        if(width >= mobileNavbarThreshold) {
            $('[data-toggle="tooltip"]').tooltip({placement: 'bottom', trigger: 'manual'}).tooltip('show');
            $('[data-toggle="tooltip"]').hover(function () {
                $(this).tooltip('destroy');
            });
            $(window).off("resize", toggleTooltip)
        }
    }

    $(window).resize(toggleTooltip);
    toggleTooltip();
});

//destroy tooltip when you click anywhere on page so it's not in the way
$(window).click(function () {
    $('[data-toggle="tooltip"]').tooltip('destroy');
});



