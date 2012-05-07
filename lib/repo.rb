class CocoaPodsNotifier
  class Repo
    attr_reader :new_pods

    def initialize
      @repos_dir = Pathname.new(File.expand_path("../../tmp/.cocoapods", __FILE__))
      Pod::Config.instance.repos_dir = @repos_dir
      Pod::Specification::Statistics.instance.cache_expiration = Time.mktime(2012,1,1).to_i
    end

    def master_dir
      @repos_dir + 'master'
    end

    def setup
      return if (master_dir).exist?
      @repos_dir.mkpath
      puts '-> Cloning Specs Repo'.cyan unless $silent
      Dir.chdir(@repos_dir) { `git clone '#{ENV['SPECS_URL']}' master` }
      raise 'Git failed to clone the master repo' unless $?.exitstatus == 0
    end

    def git_pull
      puts '-> Updating Specs Repo'.cyan unless $silent
      Dir.chdir(master_dir) { `git pull` }
      raise 'Git failed to pull the master repo' unless $?.exitstatus == 0
    end

    def update
      old_pods = pods
      git_pull
      @new_pods = pods - old_pods
    end

    def sets
      Pod::Source.all_sets.sort_by { |set| set.name.downcase }
    end

    def pods
      sets.map { |set| Pod::Command::Presenter::CocoaPod.new(set) }.sort_by(&:name)
    end

    def pod_named(name)
      pods.find { |pod| pod.name == name }
    end

    def creation_dates
      Pod::Specification::Statistics.instance.creation_dates(sets)
    end
  end
end
