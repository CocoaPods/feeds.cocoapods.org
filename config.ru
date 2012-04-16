require File.expand_path '../app', __FILE__

$stdout.sync = true
CocoapodFeed.update_feed
run CocoapodFeed
