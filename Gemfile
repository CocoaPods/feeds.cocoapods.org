# We don't install CocoaPods as a gem, but rather vendor it as a git submodule.
# The reason for this is that we don't need the Xcodeproj dependency and in
# fact makes it even impossible to install on Heroku.

source :rubygems

# Gems required by CocoaPods.
#
gem 'open4'
gem 'colored'
gem 'escape'
gem 'json'
gem 'octokit'
gem 'rake'

gem 'thin'
gem 'sinatra'
gem 'sinatra-contrib'
gem 'haml'
gem 'twitter'

group :development do
  gem 'awesome_print'
  gem 'foreman'
end
