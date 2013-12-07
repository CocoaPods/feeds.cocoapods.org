require 'sinatra'
require 'sinatra/cache'
require 'json'
require 'exceptio-ruby'
require 'colored'
require 'cocoapods-core'
require 'slim'

APP_ROOT = Pathname.new(File.expand_path('../', __FILE__))
$:.unshift((APP_ROOT + 'lib').to_s)

require 'cocoapods_notifier'

module CocoaPodsNotifier

  class CocoaPodsNotifierApp < Sinatra::Application

    # Setup
    #-------------------------------------------------------------------------#

    # The path of the RSS file. Served statically as it is located in the public
    # folder.
    #
    RSS_FILE = File.join(APP_ROOT, 'public/new-pods.rss')

    # Configurations.
    #
    configure do
      set :root, APP_ROOT.to_s

      register Sinatra::Cache
      set :cache_output_dir, File.join(APP_ROOT, 'public')
      set :cache_enabled, true
    end

    configure :development do
      require 'awesome_print'
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end

    configure :production do
      ExceptIO::Client.configure "cocoapods-feeds-cocoapods-org", ENV['EXCEPTIO_KEY']
    end

    configure :development, :production do
      $silent = false
      Pod::Specification::Set::Statistics.instance.cache_expiration = 60 * 60 * 24
      Pod::Specification::Set::Statistics.instance.cache_file = APP_ROOT + 'caches/statistics.yml'
    end

    # Repo Actions
    #-------------------------------------------------------------------------#

    def self.master_repo
      @master_repo ||= begin
        repo = Repo.new(APP_ROOT + 'tmp/.cocoapods/master')
        repo.silent = $silent
        repo
      end
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

      master_repo.new_pod_names.each { |pod_name| TwitterNotifier.new.tweet(master_repo.pod_named(pod_name)) }
      puts "-> Tweeted #{master_repo.new_pod_names.count} pods".cyan unless $silent
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
        pods = self.class.master_repo.pods
        @creation_dates = self.class.master_repo.creation_dates
        @pods_count = pods.length
        @new_pods = RSS.new(pods, @creation_dates).pods_for_feed
        @pods_tweets = {}
        @new_pods.each { |pod| @pods_tweets[pod.name] = TwitterNotifier.new.status_for_pod(pod) }
        
        slim :index
        
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
  end

end
