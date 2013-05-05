(function() {
  var Map, Venue;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Venue = (function() {
    function Venue(json) {
      this.json = json;
      this.shouts = [];
      this.checkinCount = 0;
      this.location = json.location;
    }
    Venue.prototype.addCheckin = function(checkin) {
      this.checkinCount++;
      if (checkin.shout) {
        return this.shouts.push(checkin.shout);
      }
    };
    Venue.prototype.html = function() {
      var result;
      result = "";
      result += "<h1>" + this.json.name + "</h1>";
      result += "<h2>" + this.checkinCount + " checkin(s)</h2>";
      result += this.categoryHTML();
      return result += this.shoutHTML();
    };
    Venue.prototype.categoryHTML = function() {
      var category, list;
      list = (function() {
        var _i, _len, _ref, _results;
        _ref = this.json.categories;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          category = _ref[_i];
          _results.push("<div class='category'><img src='" + category.icon + "'></div>");
        }
        return _results;
      }).call(this);
      return "<h3>Categories</h3>" + (list.join("")) + "</h3>";
    };
    Venue.prototype.shoutHTML = function() {
      var list, shout;
      list = (function() {
        var _i, _len, _ref, _results;
        _ref = this.shouts;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          shout = _ref[_i];
          _results.push("<li>" + shout + "</li>");
        }
        return _results;
      }).call(this);
      return "<h3>Shouts</h3><ul>" + (list.join("")) + "</li>";
    };
    return Venue;
  })();
  Map = (function() {
    function Map(id) {
      this.venues = {};
      this.latlng = new google.maps.LatLng(-34.397, 150.644);
      this.options = {
        zoom: 8,
        center: this.latlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      this.map = new google.maps.Map(document.getElementById(id), this.options);
      this.bounds = new google.maps.LatLngBounds();
      this.windows = [];
    }
    Map.prototype.addCheckin = function(checkin) {
      var _base, _name;
      if (!checkin.venue) {
        return;
      }
      if (!checkin.venue.name) {
        return;
      }
      if (!checkin.venue.location) {
        return;
      }
      (_base = this.venues)[_name = checkin.venue.id] || (_base[_name] = new Venue(checkin.venue));
      return this.venues[checkin.venue.id].addCheckin(checkin);
    };
    Map.prototype.buildAllVenues = function() {
      var venue, venueId, _ref, _results;
      _ref = this.venues;
      _results = [];
      for (venueId in _ref) {
        venue = _ref[venueId];
        _results.push(this.buildVenue(venue));
      }
      return _results;
    };
    Map.prototype.buildVenue = function(venue) {
      var infowindow, latlong, marker;
      infowindow = new google.maps.InfoWindow({
        content: venue.html()
      });
      latlong = new google.maps.LatLng(venue.location.lat, venue.location.lng);
      this.bounds.extend(latlong);
      this.windows.push(infowindow);
      marker = new google.maps.Marker({
        position: latlong,
        map: this.map,
        title: venue.name
      });
      google.maps.event.addListener(marker, 'click', __bind(function() {
        var window, _i, _len, _ref;
        _ref = this.windows;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          window = _ref[_i];
          window.close();
        }
        return infowindow.open(this.map, marker);
      }, this));
      return this.map.fitBounds(this.bounds);
    };
    return Map;
  })();
  window.init = function() {
    var checkin, map, _i, _len;
    map = new Map("map_canvas");
    for (_i = 0, _len = HISTORY.length; _i < _len; _i++) {
      checkin = HISTORY[_i];
      map.addCheckin(checkin);
    }
    return map.buildAllVenues();
  };
}).call(this);
