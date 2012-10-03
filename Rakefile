require 'rake/testtask'

def rvm_ruby_dir
  @rvm_ruby_dir ||= File.expand_path('../..', `which ruby`.strip)
end

namespace :travis do
  task :install_opencflite_debs do
    sh "mkdir -p debs"
    Dir.chdir("debs") do
      sh "wget http://archive.ubuntu.com/ubuntu/pool/main/i/icu/libicu44_4.4.2-2ubuntu0.11.04.1_i386.deb" unless File.exist?("libicu44_4.4.2-2ubuntu0.11.04.1_i386.deb")
      base_url = "https://github.com/downloads/CocoaPods/OpenCFLite"
      %w{ opencflite1_248-1_i386.deb opencflite-dev_248-1_i386.deb }.each do |deb|
        sh "wget #{File.join(base_url, deb)}" unless File.exist?(deb)
      end
      sh "sudo dpkg -i *.deb"
    end
  end

  task :fix_rvm_include_dir do
    unless File.exist?(File.join(rvm_ruby_dir, 'include'))
      # Make Ruby headers available, RVM seems to do not create a include dir on 1.8.7, but it does on 1.9.3.
      sh "mkdir '#{rvm_ruby_dir}/include'"
      sh "ln -s '#{rvm_ruby_dir}/lib/ruby/1.8/i686-linux' '#{rvm_ruby_dir}/include/ruby'"
    end
  end

  task :setup => [:install_opencflite_debs, :fix_rvm_include_dir] do
    sh "CFLAGS='-I#{rvm_ruby_dir}/include' bundle install"
  end
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
