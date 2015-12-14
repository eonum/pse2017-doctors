@app = {}

ready = (geolocate = true) =>
  if geolocate
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
        $('a.locatable').each (i,e) =>
          target = $(e).attr('href')
          target = target + '&location=' + @app.location
          $(e).attr('href', target)

  $('.modal').on 'show.bs.modal', =>
    console.log 'Showing map...'
    @app.map = new GMaps
      div: '#map',
      lat: @app.location[0],
      lng: @app.location[1],
      height: '100%',
      width: '100%'

    marker = @app.map.addMarker
      lat: @app.location[0],
      lng: @app.location[1],
      draggable: true

    google.maps.event.addListener marker, 'dragend',  =>
      @app.location = [marker.position.lat(), marker.position.lng()]
      console.log @app.location

    @app.map.setCenter(@app.location[0], @app.location[1])

  $(window).trigger 'resize'

  $('.modal').on 'shown.bs.modal', =>
    console.log 'refreshing map'
    @app.map.refresh()
    @app.map.setCenter(@app.location[0], @app.location[1])

  console.log 'Displaying address'
  $('#location-btn').html('<i class="fa fa-location-arrow"></i> ' + @app.address) if @app.address?

# Do not geolocate on turbolink refresh
$(document).on 'page:load', =>
  ready(false)

  $('a.locatable').each (i,e) =>
    target = $(e).attr('href')
    target = target + '&location=' + @app.location
    $(e).attr('href', target)

# Do geolocate only on hard refresh
$(document).ready ready

$(window).on 'resize', ->
  console.log 'resizing'
  $('#search-bar').parent().height($(window).height()-131)

