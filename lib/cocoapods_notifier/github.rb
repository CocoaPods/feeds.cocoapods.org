require 'octokit'

module CocoaPodsNotifier
  module GitHub
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
    def self.get_stargazer_count(url, client = nil)
      if github_url?(url)
        client ||=  Octokit::Client.new
        begin
          repo = client.repo(url)
          repo['stargazers_count']
        rescue Octokit::NotFound
          nil
        end
      end
    end

    private

    # @return [Bool] Wether the given url is a github repo.
    #
    # @param  [String] url The URL of the repo.
    #
    def self.github_url?(url)
      if url
        url.include?('github.com')
      end
    end
  end
end
