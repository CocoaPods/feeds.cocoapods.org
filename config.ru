require File.expand_path '../app', __FILE__

$stdout.sync = true
CocoapodFeed.init
run CocoapodFeed
