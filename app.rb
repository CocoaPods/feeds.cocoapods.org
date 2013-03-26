require 'sinatra'
require 'sinatra/cache'
require 'haml'
require 'json'
require 'exceptio-ruby'
require 'colored'
require 'cocoapods-core'

APP_ROOT = Pathname.new(File.expand_path('../', __FILE__))
$:.unshift (APP_ROOT + 'lib').to_s

require 'cocoapods_notifier'

module CocoaPodsNotifier

  class CocoaPodsNotifierApp < Sinatra::Application

    # Setup
    #---------------------------------------------------------------------------#

    # The path of the RSS file. Served statically as it is located in the public
    # folder.
    #
    RSS_FILE = File.join(APP_ROOT, 'public/new-pods.rss')

    # Configurations.
    #
    configure do
      set :root, APP_ROOT.to_s
      set :haml, :format => :html5

      register Sinatra::Cache
      set :cache_output_dir, File.join(APP_ROOT, 'public')
      set :cache_enabled, true

      if ENV['RACK_ENV'] == 'production'
        ExceptIO::Client.configure "cocoapods-feeds-cocoapods-org", ENV['EXCEPTIO_KEY']
      end
    end

    # Development configurations.
    #
    configure :development do
      require 'awesome_print'
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end

    require "twitter"
    ::Twitter.configure do |config|
      config.consumer_key       = ENV['CONSUMER_KEY']
      config.consumer_secret    = ENV['CONSUMER_SECRET']
      config.oauth_token        = ENV['OAUTH_TOKEN']
      config.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']
    end

    # Repo Actions
    #-------------------------------------------------------------------------#

    def master_repo
      @master_repo ||= Repo.new(APP_ROOT + 'tmp/.cocoapods/master', APP_ROOT + 'caches/statistics.yml')
    end

    # Clones the master repo from the remote and generates the feeds and
    # sends the tweets for Pods of the last commit.
    #
    # @note If the tweets for the Pods of the last commit where already sent
    #       twitter will reject them.
    #
    def self.init
      master_repo.setup_if_needed
      update
    end

    #
    #
    def self.update
      master_repo.update

      feed = RSS.new(master_repo.pods, master_repo.creation_dates).feed
      File.open(RSS_FILE, 'w') { |f| f.write(feed) }
      puts '-> RSS feed created'.cyan unless $silent

      master_repo.new_pods.each { |pod| Twitter.tweet(pod) }
      puts "-> Tweeted #{master_repo.new_pods.count} pods".cyan unless $silent
    rescue Exception => e
      puts "[!] update failed: #{e}".red
      puts e.backtrace.join("\n")
      ExceptIO::Client.log e, ENV['RACK_ENV']
    end

    # Routes
    #-------------------------------------------------------------------------#

    # The home page. Shows a link to the feed and the preview of the tweets
    # for the last 30 pods.
    #
    get '/' do
      begin
        pods = master_repo.pods
        @creation_dates = master_repo.creation_dates
        @pods_count = pods.length
        @new_pods = RSS.new(pods, @creation_dates).pods_for_feed
        @pods_tweets = {}
        @new_pods.each { |pod| @pods_tweets[pod.name] = Twitter.new(nil).tweet_preview(pod) }
        haml :index

      rescue Exception => e
        puts "[!] get / failed: #{e}".red
        puts e.backtrace.join("\n")
        ExceptIO::Client.log e, ENV['RACK_ENV']
        status 500
      end
    end

    # The secret (TM) hook used by GitHub to trigger an update of the repo.
    # It the process the RSS feed is recreated and the tweets for the Pods
    # are sent.
    #
    post "/#{ENV['HOOK_PATH']}" do
      begin
        start_time = Time.now
        payload = JSON.parse(params[:payload])

        if payload['ref'] == "refs/heads/master"
          self.class.update
          cache_expire('/index')
          status 201
          body "REINDEXED - #{(Time.now - start_time).to_i} seconds"
        else
          status 200
          body "NO UPDATES - #{(Time.now - start_time).to_i} seconds"
        end

      rescue Exception => e
        puts "[!] get /HOOK_PATH failed: #{e}".red
        puts e.backtrace.join("\n")
        ExceptIO::Client.log e, ENV['RACK_ENV']
        status 500
      end
    end

    #---------------------------------------------------------------------------#

  end

end
