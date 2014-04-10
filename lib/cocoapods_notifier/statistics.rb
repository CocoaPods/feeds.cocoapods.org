require 'config/init'
require 'cocoapods_notifier/github'

module CocoaPodsNotifier
  module Statistics
    # Returns the stargazers count of a given URL.
    #
    # @param  [String] url The URL of the repo.
    #
    # @param  [Octokit::Client] client The Octokit client to use for
    #         the request.
    #
    # @return [Fixnum, Nil] The stargazers count of the given GitHub
    #         repo if available, otherwise nil is returned.
    #
    # @note   Performs a quick validation of the given URL to save the
    #         request.
    #
    def self.get_stargazer_count(pod)
      url = pod.spec.source[:git]
      if url
        GitHub.get_stargazer_count(url, OCTOKIT_CLIENT)
      end
    end
  end
end

