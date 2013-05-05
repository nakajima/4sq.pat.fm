window.init = ->
  map = new Map("map_canvas")

  for checkin in HISTORY
    map.addCheckin(checkin)

  map.buildAllVenues()
