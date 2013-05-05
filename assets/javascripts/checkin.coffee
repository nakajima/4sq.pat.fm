class Venue
  constructor: (json) ->
    @json = json
    @shouts = []
    @checkinCount = 0
    @location = json.location

  addCheckin: (checkin) ->
    @checkinCount++
    @shouts.push checkin.shout if checkin.shout

  html: ->
    result = ""
    result += "<h1>#{@json.name}</h1>"
    result += "<h2>#{@checkinCount} checkin(s)</h2>"
    result += @categoryHTML()
    result += @shoutHTML()

  categoryHTML: ->
    list = for category in @json.categories
      "<div class='category'><img src='#{category.icon}'></div>"
    "<h3>Categories</h3>#{list.join("")}</h3>"

  shoutHTML: ->
    list = for shout in @shouts
      "<li>#{shout}</li>"
    "<h3>Shouts</h3><ul>#{list.join("")}</li>"

class Map
  constructor: (id) ->
    @venues = {}
    @latlng = new google.maps.LatLng(-34.397, 150.644)
    @options = {
      zoom: 8,
      center: @latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }

    # Google Maps Attributes
    @map = new google.maps.Map(document.getElementById(id), @options)
    @bounds = new google.maps.LatLngBounds()
    @windows = []

  addCheckin: (checkin) ->
    return unless checkin.venue
    return unless checkin.venue.name
    return unless checkin.venue.location
    @venues[checkin.venue.id] ||= new Venue(checkin.venue)
    @venues[checkin.venue.id].addCheckin(checkin)

  buildAllVenues: ->
    for venueId, venue of @venues
      @buildVenue(venue)

  buildVenue: (venue) ->
    infowindow = new google.maps.InfoWindow({ content: venue.html() })
    latlong = new google.maps.LatLng(venue.location.lat, venue.location.lng)
    @bounds.extend(latlong)
    @windows.push(infowindow)

    marker = new google.maps.Marker({
      position: latlong,
      map: @map,
      title: venue.name
    })

    google.maps.event.addListener marker, 'click', =>
      for window in @windows
        window.close()
      infowindow.open(@map, marker)

    @map.fitBounds(@bounds)

window.init = ->
  map = new Map("map_canvas")

  for checkin in HISTORY
    map.addCheckin(checkin)

  map.buildAllVenues()
