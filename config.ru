require File.expand_path '../app', __FILE__
require 'logger'

# Development configurations
#
configure :development do
  STDOUT.sync = true
end

# Production configuration
#
configure :production do
  log_path = APP_ROOT + 'log/sinatra.log'
  FileUtils.mkdir_p(log_path.dirname)
  log = File.new(log_path, "a")
  STDOUT.reopen(log)
  STDERR.reopen(log)
end

CocoaPodsNotifier::CocoaPodsNotifierApp.init
run CocoaPodsNotifier::CocoaPodsNotifierApp
