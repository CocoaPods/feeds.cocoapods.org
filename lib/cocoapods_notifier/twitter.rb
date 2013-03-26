# encoding: UTF-8

module CocoaPodsNotifier

  # Posts tweets about Pods.
  #
  class Twitter

    attr_accessor :twitter_client

    # @param [#update] The client to use for the update
    #
    def initialize(twitter_client)
      @twitter_client = twitter_client
    end

    # @param  [] pod
    #
    # @return [void]
    #
    def tweet(pod)
      status = message_for_pod(pod.name, pod.summary, pod.homepage)
      twitter_client.update(status)
    end

    def tweet_preview(pod)
      message_for_pod(pod.name, pod.summary, pod.homepage)
    end

    private

    # Private Helpers
    #-------------------------------------------------------------------------#

    # Returns the body for the tweet of the given Pod taking into account
    # to truncate the summary.
    #
    # @note   The summary is a required attribute of a Specification.
    #
    # @param  [] pod
    #
    # @return [String] The body of the tweet.
    #
    def message_for_pod(pod_name, pod_summary, pod_homepage)
      message = "[#{pod_name}] #{pod_summary}"
      if message.length > message_max_length
        message = truncate_message(message, message_max_length, ELLIPSIS_STRING)
      end
      message << LINK_SEPARATOR_STRING
      message << pod_homepage
      message
    end

    # Truncates the given message to the given length using the given ellipsis
    # string. Trailing whitespace, comas and punctuation is removed.
    #
    # @param  [String] message
    #         The message to truncate.
    #
    # @param  [Fixnum] length
    #         The length to which truncate the message, including the ellipsis
    #         string length.
    #
    # @param  [String] ellipsis_string
    #         The ellipsis string to append after the truncated message.
    #
    # @return [String] The truncated message.
    #
    def truncate_message(message, length, ellipsis_string)
      chars = message.scan(/./mu)
      max_lenght_with_ellipsis = length - ellipsis_string.length - 1
      allowed_chars = chars[0..max_lenght_with_ellipsis]
      allowed_chars.join.gsub(/ ?\.?,?$/,'') + ellipsis_string
    end

    # @return [Fixnum] The maximum length of the message for the tweet.
    #
    def message_max_length
      MESSAGE_MAX_LENGTH - LINK_MAX_LENGTH - LINK_SEPARATOR_STRING.length
    end

    private

    # Constants
    #-------------------------------------------------------------------------#

    # @return [Fixnum] The maximum length of the message.
    #
    MESSAGE_MAX_LENGTH = 140

    # @return [Fixnum] The maximum length of a link. Twitter shortens http urls
    # to 20 characters and https ones to 21.
    #
    LINK_MAX_LENGTH = 21

    # @return [String] The string to use for the ellipsis.
    #
    LINK_SEPARATOR_STRING = ' '

    # @return [String] The string to use for the ellipsis.
    #
    ELLIPSIS_STRING = '…'

    #-------------------------------------------------------------------------#

  end
end
