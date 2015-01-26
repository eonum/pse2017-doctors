@app = {}

ready = =>
  $(window).on 'resize', ->
    $('#search-bar').parent().height($(window).height()-110)
  $(window).trigger 'resize'

  if $('#map').length > 0
    GMaps.geolocate
      success: (position) =>
        @app.location = [position.coords.latitude, position.coords.longitude]
      always: =>
        map = new GMaps
          div: '#map',
          lat: @app.location[0],
          lng: @app.location[1],
          height: '100%',
          width: '100%'

        map.addMarker
          lat: @app.location[0],
          lng: @app.location[1],
          draggable: true

        map.setCenter(@app.location[0], @app.location[1])

        @app.map = map

        GMaps.geocode
          lat: @app.location[0],
          lng: @app.location[1],
          callback: (results, status) ->
            if status is 'OK'
              $('#location-btn').html('<i class="fa fa-location-arrow"></i> ' + results[0].formatted_address)
              $.cookie 'location', results[0].formatted_address,
                expires: 1,
                path: '/'

      not_supported: ->
        alert 'Browser does not support geolocation'
      error: ->
        alert 'Geolocation failed or denied by user'

  $('.modal').on 'shown.bs.modal', =>
    @app.map.refresh()
    @app.map.setCenter(@app.location[0], @app.location[1])

$(document).on 'page:load', ready
jQuery ready