ready = ->
  $("a[rel~=popover], .has-popover").popover
    placement : 'bottom',
    trigger : 'hover'
    delay:
      show: "800",
      hide: "100"

  $("a[rel~=tooltip], .has-tooltip").tooltip()

$(document).on('turbolinks:load', ready)

