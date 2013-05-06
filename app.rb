require "rubygems"
require "sinatra"
require "em-http"
require "open-uri"
require "json"
require "redis"
require "./lib/credentials"
require "./lib/core_ext"
require "./lib/history_loader"
require "./lib/foursquare"

$stdout.sync = true

class FoursquareMap < Sinatra::Base
  enable :logging
  enable :static
  enable :sessions

  set :root, File.dirname(__FILE__)
  set :public, root + "/public"
  
  configure do
    CLIENT_KEY = ENV['FOURSQUARE_CLIENT_ID']
    CLIENT_SECRET = ENV['FOURSQUARE_CLIENT_SECRET']

    if ENV["RACK_ENV"] == "production"
      OUR_HOST = "http://4sq.pat.fm"
      $redis = Redis.connect(:url => ENV['REDISTOGO_URL'])
    else
      OUR_HOST = "http://localhost:4567"
      $redis = Redis.connect :url => "redis://localhost:16379"
    end
  end
  
  helpers do
    def js_template(name)
      partial = "_#{name}".to_sym
      "<script type='text/html' id='_template_#{name}'>#{erb(partial)}</script>"
    end
  end
  
  before do
    p session
  end

  get "/" do
    @authorize_url = Foursquare.authorize_url
    session[:ok] = true
    erb :index
  end

  get "/map" do
    if history = $redis.get(session[:history_id])
      @history = history.decompress
      $redis.del(session[:history_id]) if ENV['RACK_ENV'] == 'production'
      erb :map
    else
      redirect "/reset"
    end
  end

  get "/ping" do
    $redis.get(session[:history_id]) ? "/map" : ""
  end

  get "/callback" do
    puts "got to callback"
    session[:history_id] = rand(10000)
    session[:access_token] = Foursquare.get_access_token(params[:code])
    puts "session[:access_token] # => #{session[:access_token]}"
    EM.next_tick { HistoryLoader.new(session).perform }
    redirect '/'
  end

  get "/reset" do
    session[:history_id] && $redis.del(session[:history_id])
    session[:history_id] = session[:access_token] = nil
    redirect "/"
  end
end
