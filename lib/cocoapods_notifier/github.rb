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
      if repo_id = repo_id_from_url(url)
        client ||=  Octokit::Client.new
        begin
          repo = client.repo(repo_id)
          repo['stargazers_count']
        rescue Octokit::NotFound
          nil
        end
      end
    end

    private

    # Returns the repo ID given it's URL.
    #
    # @param [String] url
    #        The URL of the repo.
    #
    # @return [String] the repo ID.
    # @return [Nil] if the given url is not a valid github repo url.
    #
    def self.repo_id_from_url(url)
      result = url[%r{github.com/([^/]*/[^/]*)\.*}, 1]
      result.sub(/.git$/, '') if result
    end
  end
end
