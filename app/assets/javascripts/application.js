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
//= require jquery.turbolinks
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

$(document).ready(function(){
    $(window).on('resize',
        function(){
            if ( $(window).width() < 768 ){
                $('[data-toggle="tooltip"]').tooltip('destroy');
            }
            else{
                $('[data-toggle="tooltip"]').tooltip({placement: 'bottom',trigger: 'manual'}).tooltip('show');
                $('[data-toggle="tooltip"]').hover(function(){$(this).tooltip('destroy');});
            }});
    if ( $(window).width() < 768 ){
        $('[data-toggle="tooltip"]').tooltip('destroy');
    }
    else{
        $('[data-toggle="tooltip"]').tooltip({placement: 'bottom',trigger: 'manual'}).tooltip('show');
        $('[data-toggle="tooltip"]').hover(function(){$(this).tooltip('destroy');});
    }
});
