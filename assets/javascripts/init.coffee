window.init = ->
  window.map = new Map(document.getElementById "map_canvas")

  for checkin in HISTORY
    map.addCheckin(checkin)

  map.buildAllVenues()
