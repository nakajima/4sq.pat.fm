require "rubygems"
require "sinatra"
require "em-http"
require "open-uri"
require "json"
require "redis"
require "./lib/core_ext"
require "./lib/history_loader"
require "./lib/foursquare"

$stdout.sync = true

OUR_HOST = ENV['OUR_HOST'] || "http://localhost:4567"
CLIENT_KEY = ENV['FOURSQUARE_CLIENT_ID']
CLIENT_SECRET = ENV['FOURSQUARE_CLIENT_SECRET']

class FoursquareMap < Sinatra::Base
  enable :logging
  enable :static
  enable :sessions

  set :root, File.dirname(__FILE__)
  set :public, root + "/public"
  
  configure do
    $redis = Redis.connect(:url => ENV['REDISTOGO_URL'] || "redis://localhost:16379")
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
  
  get "/loading" do
    @loading = true
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
    # Just grab a random ID to look up the history later. Using rand is a bulletproof method
    # that always guarantees a unique result. Always. Never fails. Ever.
    session[:history_id] = rand(10000)
    session[:access_token] = Foursquare.get_access_token(params[:code])
    puts "session[:access_token] # => #{session[:access_token]}"
    EM.next_tick { HistoryLoader.new(session).perform }
    redirect '/loading'
  end

  get "/reset" do
    session[:history_id] && $redis.del(session[:history_id])
    session[:history_id] = session[:access_token] = nil
    redirect "/"
  end
end
