require 'bundler/setup'
require 'rake/testtask'

Rake::TestTask.new("test" => ["test:app", "test:rss", "test:pod_twitter"])

Rake::TestTask.new("test:app") do |t|
  t.pattern = "test/app_test.rb"
end

Rake::TestTask.new("test:rss") do |t|
  t.pattern = "test/rss_test.rb"
end

Rake::TestTask.new("test:pod_twitter") do |t|
  t.pattern = "test/pod_twitter_test.rb"
end

task :default => :test
