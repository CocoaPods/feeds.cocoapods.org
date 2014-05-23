
task :default => :spec

#-- Bootstrap ----------------------------------------------------------------#

desc 'Initializes your working copy to run the specs'
task :bootstrap do
  title 'Environment bootstrap'
  sh 'bundle install'
end

#-- Run ----------------------------------------------------------------------#

desc 'Starts the process locally for development'
task :run do
  title 'Serving application on http://localhost:4567'
  sh 'env PORT=4567 RACK_ENV=development foreman start'
end

#-- Env ----------------------------------------------------------------------#

task :env do
  $LOAD_PATH.unshift(File.expand_path('../', __FILE__))
  require 'config/init'
end

#-- DB -----------------------------------------------------------------------#

namespace :db do
  def schema
    require 'terminal-table'
    result = ''
    DB.tables.each do |table|
      result << "#{table}\n"
      schema = DB.schema(table)
      terminal_table = Terminal::Table.new(
        headings: [:name, *schema[0][1].keys],
        rows: schema.map { |c| [c[0], *c[1].values.map(&:inspect)] }
      )
      result << "#{terminal_table}\n\n"
    end
    result
  end

  desc 'Show schema'
  task schema: :env do
    puts schema
  end

  desc 'Run migrations'
  task :migrate do
    Rake::Task[:env].invoke
    version = ENV['version'].to_i if ENV['version']
    migration_version = Sequel::Migrator.run(DB, File.join(ROOT, 'db/migrations'), target: version)
    puts "Migrated to version #{migration_version}"
    schema
    File.open('db/schema.txt', 'w') { |file| file.write(schema) }
  end

  desc 'Drop all DBs'
  task :drop do
    `dropdb pod_feeds_app_test`
    `dropdb pod_feeds_app_development`
    `dropdb pod_feeds_app_production`
  end

  desc 'Create all DBs'
  task :create do
    `createdb -h localhost pod_feeds_app_test -E UTF8`
    `createdb -h localhost pod_feeds_app_development -E UTF8`
    `createdb -h localhost pod_feeds_app_production -E UTF8`
  end

  desc 'Drop, create, and migrate all DBs'
  task :bootstrap do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    %w(test development production).each do |env|
      sh "env RACK_ENV=#{env} rake db:migrate"
    end
  end
end

#-- Console ------------------------------------------------------------------#

desc 'Starts a interactive console with the model env loaded'
task :console do
  exec 'irb', '-I', File.expand_path('../', __FILE__), '-r', 'config/init'
end

#-- Spec ---------------------------------------------------------------------#

desc 'Run the specs'
task :spec do
  sh "bundle exec bacon #{FileList['spec/**/*_spec.rb'].shuffle.join(' ')}"
end

#-- Kick ---------------------------------------------------------------------#

desc 'Use Kicker to automatically run specs'
task :kick do
  exec 'kicker'
end

#-- Helpers ------------------------------------------------------------------#

def title(title)
  cyan_title = "\033[0;36m#{title}\033[0m"
  puts
  puts '-' * 80
  puts cyan_title
  puts '-' * 80
  puts
end
