# The Search class is used with Map#buildFilteredVenues.
# So far you can filter by name.
# 
#   search = new Search
#   search.name "cool"
#
# Then you do this:
#
#  map.reset()
#  map.buildFilteredVenues(search.result)
#
# I wanna add stuff like search.before and search.after. We'll get there.
class @Search
  constructor: ->
    @filters = []

  result: (venue) =>
    for filter in @filters
      return false unless filter(venue)
    true

  name: (string) =>
    @filters.push (venue) ->
      venue.name.toLowerCase().indexOf(string) > -1
