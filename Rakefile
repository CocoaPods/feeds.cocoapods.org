
task :default => :spec

#--------------------------------------#

namespace :spec do
  desc "Run all the specs"
  task :all do
    sh "bundle exec bacon #{specs('**')}"
  end

  desc "Run the unit specs"
  task :unit do
    sh "bundle exec bacon #{specs('unit/**')}"
  end
end

task :spec => 'spec:all'

def specs(dir)
  FileList["spec/#{dir}/*_spec.rb"].shuffle.join(' ')
end

#--------------------------------------#

