class CocoaPodsNotifier
  class Repo
    def initialize
      @repos_dir = Pathname.new(File.expand_path("../../tmp/.cocoapods", __FILE__))
      Pod::Config.instance.repos_dir = @repos_dir
      Pod::Specification::Statistics.instance.cache_expiration = Time.mktime(2012,1,1).to_i
    end

    def setup
      return if (@repos_dir + 'master').exist?
      @repos_dir.mkpath
      puts '-> Cloning Specs Repo'.green
      Dir.chdir(@repos_dir) { `git clone '#{ENV['SPECS_URL']}' master` }
    end

    def update
      puts '-> Updating Specs Repo'.green
      Dir.chdir(@repos_dir + 'master') { `git pull` }
    end

    def sets
      Pod::Source.all_sets.sort_by { |set| set.name.downcase }
    end

    def pods
      sets.map { |set| Pod::Command::Presenter::CocoaPod.new(set) }
    end

    def pod_named(name)
      pods.select { |pod| pod.name == name }[0]
    end

    def creation_dates
      Pod::Specification::Statistics.instance.creation_dates(sets)
    end
  end
end
