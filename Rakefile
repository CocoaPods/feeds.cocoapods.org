require 'bundler/setup'
require 'rake/testtask'

desc "Install dependencies"
task :bootstrap do
  sh "git submodule update --init"
  sh "bundle install"
end

Rake::TestTask.new do |t|
  t.pattern = "test/**/*.rb"
end

Rake::TestTask.new("test:app") do |t|
  t.pattern = "test/app_test.rb"
end

Rake::TestTask.new("test:repo") do |t|
  t.pattern = "test/repo_test.rb"
end

Rake::TestTask.new("test:rss") do |t|
  t.pattern = "test/rss_test.rb"
end

Rake::TestTask.new("test:twitter") do |t|
  t.pattern = "test/twitter_test.rb"
end

task :default => :test
