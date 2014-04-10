
task :default => :spec

#--------------------------------------#

desc 'Initializes your working copy to run the specs'
task :bootstrap do
  title 'Environment bootstrap'

  puts 'Updating submodules'
  execute_command 'git submodule update --init --recursive'

  puts 'Installing gems'
  execute_command 'bundle install'
end

#--------------------------------------#

desc 'Runs the site locally'
task :run do
  title 'Running locally'
  sh 'open http://0.0.0.0:5000'
  sh 'foreman start'
end

#--------------------------------------#

namespace :spec do
  desc 'Run all the specs'
  task :all do
    sh "bundle exec bacon #{specs('**')}"
  end

  desc 'Run the unit specs'
  task :unit do
    sh "bundle exec bacon #{specs('unit/**')}"
  end
end

task :spec => 'spec:all'

def specs(dir)
  FileList["spec/#{dir}/*_spec.rb"].shuffle.join(' ')
end

#--------------------------------------#

def execute_command(command)
  if ENV['VERBOSE']
    sh(command)
  else
    output = `#{command} 2>&1`
    raise output unless $CHILD_STATUS.success?
  end
end

def title(title)
  cyan_title = "\033[0;36m#{title}\033[0m"
  puts
  puts '-' * 80
  puts cyan_title
  puts '-' * 80
  puts
end
