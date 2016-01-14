@app = {'location' : [46.950745, 7.440618]}

# geolocation: get current location
geoloc = () =>
  console.log 'Geolocating...'
  GMaps.geolocate
    success: (position) =>
      @app.location = [position.coords.latitude, position.coords.longitude]
      geocode()

# reverse gecoding: get address from location
geocode = () =>
  console.log 'Reverse geocoding ..'
  GMaps.geocode
    lat: @app.location[0],
    lng: @app.location[1],
    callback: (results, status) =>
      if status is 'OK'
        @app.address = results[0].formatted_address
        console.log @app.address
        console.log @app.location
        $('#location-btn').html('<i class="fa fa-location-arrow"></i> ' + @app.address)
        $.cookie 'location', @app.address,
          expires: 1,
          path: '/'
    $('a.locatable').each (i,e) =>
      target = $(e).attr('href')
      target = target + '&location=' + @app.location
      $(e).attr('href', target)

# show map and get location
ready = (geolocate = true) =>
  location = getUrlParameter('location')
  if !location? && geolocate
    geoloc()
  else
    if location?
      location = location.split(',')
      @app.location[0] = parseFloat(location[0])
      @app.location[1] = parseFloat(location[1])
      console.log 'Set location from URL param: '
      console.log @app.location
    geocode()

  $('#map-modal').on 'show.bs.modal', =>
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

  console.log 'Displaying address'
  $('#location-btn').html('<i class="fa fa-location-arrow"></i> ' + @app.address) if @app.address?

  $('#map-modal').on 'shown.bs.modal', =>
    console.log 'refreshing map'
    @app.map.refresh()
    @app.map.setCenter(@app.location[0], @app.location[1])

  $(window).trigger 'resize'


  $('#map-modal').on 'hidden.bs.modal', =>
    comparison_url = $('#comparison').find(":selected").val()
    Turbolinks.visit(comparison_url + '?location=' + @app.location, { change: ['main-content'] })

  $('#regeolocate').click =>
    console.log 'Regeolocate'
    GMaps.geolocate
      success: (position) =>
        @app.location = [position.coords.latitude, position.coords.longitude]
        comparison_url = $('#comparison').find(":selected").val()
        Turbolinks.visit(comparison_url + '?location=' + @app.location, { change: ['main-content'] })

# Do not geolocate on turbolink refresh
$(document).on 'page:load', =>
  ready(false)

# Do geolocate only on hard refresh
$(document).ready ready

$(window).on 'resize', ->
  console.log 'resizing'
  $('#search-bar').parent().height($(window).height()-131)