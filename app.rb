require 'sinatra'
require 'haml'
require 'json'
require 'exceptio-ruby'

$:.unshift File.expand_path('../vendor/Xcodeproj/lib', __FILE__)
$:.unshift File.expand_path('../vendor/CocoaPods/lib', __FILE__)
require 'cocoapods'

class CocoaPodsNotifier < Sinatra::Application
  RSS_FILE = File.expand_path('../public/new-pods.rss', __FILE__)

  require File.expand_path '../lib/repo', __FILE__
  require File.expand_path '../lib/rss', __FILE__
  require File.expand_path '../lib/twitter', __FILE__

  configure do
    set :haml, :format => :html5
    ExceptIO::Client.configure "cocoapods-feeds-cocoapods-org", ENV['EXCEPTIO_KEY'] if ENV['RACK_ENV'] == 'production'
  end

  configure :development do
    require 'awesome_print'
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  def self.init
    is_new = Repo.new.setup
    update
  end

  def self.update
    repo = Repo.new.tap { |r| r.update }

    feed = RSS.new(repo.pods, repo.creation_dates).feed
    File.open(RSS_FILE, 'w') { |f| f.write(feed) }
    puts '-> RSS feed created'.cyan unless $silent

    repo.new_pods.each { |pod| Twitter.tweet(pod) }
    puts "-> Tweeted #{repo.new_pods.count} pods".cyan unless $silent

  rescue Exception => e
    puts "[!] update failed".red
    ExceptIO::Client.log e, ENV['RACK_ENV']
  end

  get '/' do
    begin
      repo = Repo.new
      pods = repo.pods
      @creation_dates = repo.creation_dates
      @pods_count     = pods.length
      @new_pods       = RSS.new(pods, @creation_dates).feed_pods
      @pods_tweets    = {}
      @new_pods.each { |pod| @pods_tweets[pod.name] = Twitter.status(pod) }
      haml :index
    rescue Exception => e
      ExceptIO::Client.log e, ENV['RACK_ENV']
      status 500
    end
  end

  post "/#{ENV['HOOK_PATH']}" do
    begin
      start_time = Time.now
      payload    = JSON.parse(params[:payload])
      if payload['ref'] == "refs/heads/master"
        self.class.update
        status 201
        body "REINDEXED - #{(Time.now - start_time).to_i} seconds"
      else
        status 200
        body "NO UPDATES - #{(Time.now - start_time).to_i} seconds"
      end
    rescue Exception => e
      ExceptIO::Client.log e, ENV['RACK_ENV']
      status 500
    end
  end
end
