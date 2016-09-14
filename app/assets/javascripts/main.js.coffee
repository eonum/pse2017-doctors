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
        @app.address = results[0].formatted_address.replace(', Schweiz', '')
        console.log @app.address
        console.log @app.location
        $('#location-input').val(@app.address)

        $.cookie 'location', @app.address,
          expires: 1,
          path: '/'
    $('a.locatable').each (i,e) =>
      target = $(e).attr('href')
      target = target + '&location=' + @app.location
      $(e).attr('href', target)

# show map and get location
ready = (geolocate = true) =>
  $mapModal = $('#map-modal')
  $locationInput = $('#location-input')

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

  $mapModal.on 'show.bs.modal', =>
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
    $("#map-modal").show()
    calculateMapSize()

  console.log 'Displaying address'
  $locationInput.val(@app.address) if @app.address?

  $mapModal.on 'shown.bs.modal', =>
    console.log 'refreshing map'
    @app.map.refresh()
    @app.map.setCenter(@app.location[0], @app.location[1])

  $(window).trigger 'resize'


  $mapModal.on 'hidden.bs.modal', =>
    comparison_url = $('#comparison').find(":selected").val()
    Turbolinks.visit(comparison_url + '?location=' + @app.location, { change: ['main-content'] })

  $('#regeolocate').click =>
    console.log 'Regeolocate'
    GMaps.geolocate
      success: (position) =>
        @app.location = [position.coords.latitude, position.coords.longitude]
        comparison_url = $('#comparison').find(":selected").val()
        Turbolinks.visit(comparison_url + '?location=' + @app.location, { change: ['main-content'] })

  # geocoding with address as input
  $locationInput.keydown =>
    if (event.keyCode == 13)
      console.log 'Geolocate using address'
      GMaps.geocode
        address: $('#location-input').val(),
        region: 'ch',
        callback: (position, status) =>
          location = position[0].geometry.location
          @app.location = [location.lat(), location.lng()]
          comparison_url = $('#comparison').find(":selected").val()
          Turbolinks.visit(comparison_url + '?location=' + @app.location, { change: ['main-content'] })
      return false

  # select all text when click on address bar
  $locationInput.click =>
    $locationInput.select()




# Do not geolocate on turbolink refresh
#$(document).on 'page:load', =>
#  ready(false)

# Do geolocate only on hard refresh
$(document).ready ready
$(document).on 'turbolinks:load', =>
  ready(false)
  # Google Analytics tracking
  ga('send', 'pageview', window.location.pathname)

$(window).on 'resize', ->
  calculateMapSize()
  console.log 'resizing'
  $('#search-bar').parent().height($(window).height()-131)

calculateMapSize = ->
  $(".modal-body").css({'height': $(".modal-content").outerHeight()-$(".modal-header").outerHeight()-$(".modal-footer").outerHeight()})

# creates all tooltips in the navbar, as soon as the site gets or is bigger than 768px (changes from mobile to desktop version)
# in the mobile-view the tooltips would get created at the wrong place

$(document).ready ->
  tooltipDestroyed = false
  $tooltipHolder = $('[data-toggle="tooltip"]')
  toggleTooltip = ->
    width = $(window).width()
    mobileNavbarThreshold = 768
    if width >= mobileNavbarThreshold && !tooltipDestroyed
      $tooltipHolder.tooltip(
        placement: 'bottom'
        trigger: 'manual').tooltip 'show'
      $tooltipHolder.hover ->
        $(this).tooltip 'destroy'
        tooltipDestroyed = true

    if width < mobileNavbarThreshold
      $tooltipHolder.tooltip 'destroy'

  #destroy tooltip when you click anywhere on page so it's not in the way
  $(window).click ->
    $tooltipHolder.tooltip 'destroy'
    tooltipDestroyed = true

  $(window).resize toggleTooltip
  toggleTooltip()



