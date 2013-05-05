require "rubygems"
require "sinatra"
require "em-http"
require "quimby"
require "json"
require "redis"
require "./lib/credentials"
require "./lib/core_ext"
require "./lib/history_loader"

class FoursquareMap < Sinatra::Base
  enable :static
  enable :sessions
  set :root, File.dirname(__FILE__)
  set :public, root + "/public"

  get "/" do
    @authorize_url = Foursquare::Base.new(CLIENT_KEY, CLIENT_SECRET).authorize_url(OUR_HOST + "/callback")
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
    session[:history_id] = rand(10000)
    session[:access_token] = Foursquare::Base.new(CLIENT_KEY, CLIENT_SECRET).access_token(params[:code], OUR_HOST + "/callback")
    EM.next_tick { HistoryLoader.new(session).perform }
    redirect "/"
  end

  get "/reset" do
    session[:history_id] && $redis.del(session[:history_id])
    session[:history_id] = session[:access_token] = nil
    redirect "/"
  end
end
