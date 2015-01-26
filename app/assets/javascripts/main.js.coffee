jQuery ->
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition (position)->
      #alert position.coords
  else
    alert "Geolocation is not supported by this browser."
