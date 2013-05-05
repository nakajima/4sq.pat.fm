class @Venue
  constructor: (json) ->
    @json = json
    @shouts = []
    @checkinCount = 0
    @location = json.location

  addCheckin: (checkin) ->
    @checkinCount++
    @shouts.push { text: checkin.shout } if checkin.shout

  html: ->
    @name = @json.name
    @categories = @json.categories
    console.info @categories
    Template.render "venue", this