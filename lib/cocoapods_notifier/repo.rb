module CocoaPodsNotifier

  # Interface for the CocoaPods master repo.
  #
  class Repo

    # @return [Pathname] The path where the master repo is stored.
    #
    attr_reader :master_repo_dir

    # @param  [Pathname] master_repo_dir @see master_repo_dir
    #
    # @param  [Pathname] statistics_cache_file
    #         The cache file to use for the statistics client. A cache file is
    #         used because computing the creation dates from the git meta-data
    #         is computationally expensive.
    #
    def initialize(master_repo_dir)
      @master_repo_dir = master_repo_dir
    end

    # @return [String]
    #
    def master_repo_url
      "https://github.com/CocoaPods/Specs.git"
    end

    attr_accessor :silent

    public

    # Pods
    #-------------------------------------------------------------------------#

    # @return [Array<Pod::Specification::Set>]
    #
    def sets
      Pod::Source.new(master_repo_dir).pod_sets.sort_by { |set| set.name.downcase }
    end

    # @return [Array<Pod::Specification::Set::Presenter>] the list of all
    #         the Pods available in the repo sorted by name.
    #
    # @note   The Presenter is used because it takes care of massaging the
    #         specifications across the CocoaPods clients for a consistent
    #         experience.
    #
    def pods
      sets.map { |set| Pod::Specification::Set::Presenter.new(set) }.sort_by(&:name)
    end

    # @return [Array<String>] The names of the pods.
    #
    def pod_names
      pods.map(&:name)
    end

    # @return [Pod::Specification::Set::Presenter]
    #
    def pod_named(name)
      pods.find { |pod| pod.name == name }
    end

    # @return [Hash{String => Time}] The date in which the first podspec of
    #         each Pod appeared for the first time in the master repo.
    #
    def creation_dates
      Pod::Specification::Set::Statistics.instance.creation_dates(sets)
    end

    public

    # Initialization & Update
    #-------------------------------------------------------------------------#

    # @return [void]
    #
    def setup_if_needed
      return if (master_repo_dir).exist?
      title("Cloning Specs Repo (in #{master_repo_dir})")
      master_repo_dir.dirname.mkpath
      title("Done")
      git("clone '#{master_repo_url}' '#{master_repo_dir}'")
    end

    # Updates the master repo against its git remote.
    #
    # @raise  If the `git pull` command fails.
    #
    # @return [void]
    #
    def update
      old_pod_names = pod_names
      title("Updating Specs Repo (in #{master_repo_dir})")
      git('pull', master_repo_dir)
      @new_pod_names = pod_names - old_pod_names
      title("New Pods: #{@new_pod_names}")
    end

    # @return [Array<String>] The names of the new pods after the update.
    #
    attr_reader :new_pod_names

    private

    # Private Helpers
    #-------------------------------------------------------------------------#

    # Executes the given Git command.
    #
    # @param  [String] command
    #         The command to execute.
    #
    # @param  [String, Pathname] dir
    #         The directory in which to execute the command.
    #
    # @return [Bool] Whether the command was executed successfully.
    #
    def git(command, dir = Dir.pwd)
      Dir.chdir(dir) do
        output = `git #{command}`
        unless $?.exitstatus.zero?
          puts "git #{command} (in #{dir})"
          puts output
          raise 'Git command failed'
        end
      end
    end

    # Prints the given title.
    #
    # @return [void]
    #
    def title(string)
      unless silent
        puts "-> \033[0;36m#{string}\e[0m" 
      end
    end

    #-------------------------------------------------------------------------#

  end
end
