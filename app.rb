$:.unshift File.expand_path('../vendor/CocoaPods/lib', __FILE__)
$:.unshift File.expand_path('../vendor/Xcodeproj/lib', __FILE__)

require 'sinatra'
require 'haml'
require 'cocoapods'
require 'awesome_print'
require 'sinatra/reloader'
require 'json'

class CocoaPodsNotifier < Sinatra::Application
  RSS_FILE = File.expand_path('../public/new-pods.rss', __FILE__)

  require File.expand_path '../lib/repo', __FILE__
  require File.expand_path '../lib/rss', __FILE__
  require File.expand_path '../lib/twitter', __FILE__

  configure do
    set :haml, :format => :html5
  end

  configure :development do
    register Sinatra::Reloader
  end

  def self.init
    Repo.new.setup
    update(true, false)
  end

  def self.update(feed = true, tweet = false)
    repo  = Repo.new
    old   = repo.pods
    repo.update
    pods  = repo.pods

    if feed
      feed = RSS.new(pods, repo.creation_dates).feed
      File.open(RSS_FILE, 'w') { |f| f.write(feed) }
      puts '-> RSS feed created'.blue
    end

    if tweet
      delta = pods - old
      delta.each { |pod| Twitter.tweet(pod) }
      puts "-> Tweeted #{delta.length} pods".blue
    end
  end

  get '/' do
    repo = Repo.new
    pods = repo.pods
    @creation_dates = repo.creation_dates
    @pods_count     = pods.length
    @new_pods       = RSS.new(pods, @creation_dates).feed_pods
    @pods_tweets    = {}
    @new_pods.each { |pod| @pods_tweets[pod.name] = Twitter.status(pod) }
    haml :index
  end

  post "/#{ENV['HOOK_PATH']}" do
    start_time = Time.now
    payload    = JSON.parse(params[:payload])
    if payload['ref'] == "refs/heads/master"
      self.class.update(true, true)
      status 201
      body "REINDEXED - #{(Time.now - start_time).to_i} seconds"
    else
      status 200
      body "NO UPDATES - #{(Time.now - start_time).to_i} seconds"
    end
  end
end
