class HistoryLoader
  def initialize(session)
    @session = session
  end

  def perform
    request "/users/self" do |json|
      user = json["user"]
      checkin_count = user["checkins"]["count"].to_i
      load_checkins(checkin_count)
    end
  end

  private

  def load_checkins(checkin_count)
    multi = EventMachine::MultiRequest.new
    0.upto((checkin_count / 250) + 1) do |offset|
      request = EventMachine::HttpRequest.new("https://api.foursquare.com/v2/users/self/checkins").get(:query => {
        :limit => 250,
        :offset => offset * 250,
        :oauth_token => access_token
      })
      multi.add(offset, request)
    end

    multi.callback do
      checkins = []
      multi.responses[:callback].values.each do |req|
        checkins += JSON.parse(req.response)["response"]["checkins"]["items"]
      end
      set(history_id, checkins)
    end
  end

  def set(key, content)
    $redis.set(key, content.to_json.compress)
  end

  def get(key, default=nil)
    if content = $redis.get(key)
      JSON.parse(content.decompress)
    else
      default
    end
  end

  def request(path, params={}, &block)
    puts "Requesting: #{path} | #{params.inspect}"

    params.update :oauth_token => access_token
    http = EventMachine::HttpRequest.new("https://api.foursquare.com/v2" + path).get(:query => params)
    http.callback do
      block.call JSON.parse(http.response)["response"]
    end
  end

  def history_id
    @session[:history_id].to_s
  end

  def access_token
    @session[:access_token]
  end
end
