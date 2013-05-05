module Foursquare
  BASE = 'https://foursquare.com'
  
  def self.get_access_token(code)
    base = "#{BASE}/oauth2/access_token?"
    params = [
      "client_id=#{CLIENT_KEY}",
      "client_secret=#{CLIENT_SECRET}",
      "grant_type=authorization_code",
      "redirect_uri=#{OUR_HOST}/callback",
      "code=#{code}"
    ].join '&'
    
    response = open(base + params).read
    puts response
    
    JSON.parse(response)['access_token']
  end
  
  def self.authorize_url
    "#{BASE}/oauth2/authenticate?client_id=#{CLIENT_KEY}&response_type=code&redirect_uri=#{OUR_HOST}/callback"
  end
end