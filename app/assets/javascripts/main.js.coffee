@app = {}

ready = =>
  console.log 'Geolocating...'
  GMaps.geolocate
    success: (position) =>
      @app.location = [position.coords.latitude, position.coords.longitude]
      GMaps.geocode
        lat: @app.location[0],
        lng: @app.location[1],
        callback: (results, status) =>
          if status is 'OK'
            @app.address = results[0].formatted_address
            $('#location-btn').html('<i class="fa fa-location-arrow"></i> ' + @app.address)
            $.cookie 'location', @app.address,
              expires: 1,
              path: '/'

  $('.modal').on 'show.bs.modal', =>
    console.log 'Showing map...'
    @app.map = new GMaps
      div: '#map',
      lat: @app.location[0],
      lng: @app.location[1],
      height: '100%',
      width: '100%'

    @app.map.addMarker
      lat: @app.location[0],
      lng: @app.location[1],
      draggable: true

    @app.map.setCenter(@app.location[0], @app.location[1])

  $(window).trigger 'resize'

  $('.modal').on 'shown.bs.modal', =>
    console.log 'refreshing map'
    @app.map.refresh()
    @app.map.setCenter(@app.location[0], @app.location[1])

  console.log 'Displaying address'
  $('#location-btn').html('<i class="fa fa-location-arrow"></i> ' + @app.address) if @app.address?

$(document).on 'page:load', ready
$(document).ready ready
$(window).on 'resize', ->
  console.log 'resizing'
  $('#search-bar').parent().height($(window).height()-131)


#ready = =>
#  $(window).on 'resize', ->
#    $('#search-bar').parent().height($(window).height()-131)
#  $(window).trigger 'resize'
#  console.log 'Geolocating..'
#  if $('#map').length > 0
#    GMaps.geolocate
#      success: (position) =>
#        @app.location = [position.coords.latitude, position.coords.longitude]
#      always: =>
#        map = new GMaps
#          div: '#map',
#          lat: @app.location[0],
#          lng: @app.location[1],
#          height: '100%',
#          width: '100%'
#
#        map.addMarker
#          lat: @app.location[0],
#          lng: @app.location[1],
#          draggable: true
#
#        map.setCenter(@app.location[0], @app.location[1])
#
#        @app.map = map
#
#        GMaps.geocode
#          lat: @app.location[0],
#          lng: @app.location[1],
#          callback: (results, status) ->
#            if status is 'OK'
#              $('#location-btn').html('<i class="fa fa-location-arrow"></i> ' + results[0].formatted_address)
#              $.cookie 'location', results[0].formatted_address,
#                expires: 1,
#                path: '/'
#
#      not_supported: ->
#        alert 'Browser does not support geolocation'
#      error: ->
#        alert 'Geolocation failed or denied by user'
#
#$(document).on 'page:load', =>
#  console.log @app.location
#jQuery ready
#
#$('.modal').on 'shown.bs.modal', =>
#  console.log 'Refreshing map'
#  @app.map.refresh()
#  @app.map.setCenter(@app.location[0], @app.location[1])