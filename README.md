## foursquare history map ##

View all of the venues you've checked in on a google map.

http://4sq.pat.fm

### development ###

[![Code Climate](https://codeclimate.com/github/nakajima/4sq.pat.fm.png)](https://codeclimate.com/github/nakajima/4sq.pat.fm)

You'll need to register a Foursquare app for local development: https://foursquare.com/developers/register

Make sure the "Redirect URI" is `http://localhost:4567/callback`, like so:

![https://f.cloud.github.com/assets/483/464409/d1644bb8-b5e0-11e2-8053-17c03a40a03b.jpg](https://f.cloud.github.com/assets/483/464409/d1644bb8-b5e0-11e2-8053-17c03a40a03b.jpg)

Then do this:

    $ bundle
    $ export FOURSQUARE_CLIENT_ID=your-foursquare-client-id
    $ export FOURSQUARE_CLIENT_SECRET=your-foursquare-client-secret
    $ thin start -p 4567

