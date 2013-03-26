require File.expand_path '../app', __FILE__

# TODO this is how it should be in production, needs to be updated for local dev.
#$stdout.sync = true
log = File.new("log/sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

CocoaPodsNotifier::CocoaPodsNotifierApp.init
run CocoaPodsNotifier::CocoaPodsNotifierApp
