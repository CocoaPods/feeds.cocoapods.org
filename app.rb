$:.unshift File.expand_path('../vendor/CocoaPods/lib', __FILE__)
$:.unshift File.expand_path('../vendor/Xcodeproj/lib', __FILE__)

require 'sinatra'
require 'haml'
require 'cocoapods'
require 'awesome_print'
require 'sinatra/reloader'
require 'json'

class CocoapodFeed < Sinatra::Application
  require File.expand_path '../lib/repo', __FILE__
  require File.expand_path '../lib/rss', __FILE__
  require File.expand_path '../lib/twitter', __FILE__

  configure do
    set :haml, :format => :html5
  end

  configure :development do
    register Sinatra::Reloader
  end

  def self.update_feed
    repo = Repo.new
    repo.update

    feed = Rss.new(repo.pods, repo.creation_dates).feed
    feed_file = './public/new-pods.rss'
    File.open(feed_file, 'w') { |f| f.write(feed) }
    puts '-> RSS feed created'.magenta
  end

  get '/' do
    repo = Repo.new
    @creation_dates = repo.creation_dates
    @pods           = Rss.new(repo.pods, @creation_dates).feed_pods
    haml :index
  end

  post "/#{ENV['HOOK_PATH']}" do
    start_time = Time.now
    payload    = JSON.parse(params[:payload])

    if payload['ref'] == "refs/heads/master"
      repo     = Repo.new
      old_pods = repo.pods
      old_pods.reject!{|pod| pod.name == "PrettyKit"}

      self.class.update_feed

      new_pods   = repo.pods
      added_pods = new_pods - old_pods
      added_pods.each { |pod| puts PodTwitter.tweet(pod) }

      status 200
      body "REINDEXED - #{(Time.now - start_time).to_i} seconds"
    else
      status 200
      body "NO UPDATES - #{(Time.now - start_time).to_i} seconds"
    end
  end
end
