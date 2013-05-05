class @Map
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
    infowindow = new google.maps.InfoWindow({ content: venue.html(), boxStyle: { borderRadius: '4px' } })
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