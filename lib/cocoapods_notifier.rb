module FeedsApp
  require 'cocoapods-core'
  Pod = ::Pod

  # Only to silence the deprecation warning.
  require 'i18n'
  I18n.enforce_available_locales = false

  require 'cocoapods_notifier/rss'
  require 'cocoapods_notifier/twitter_notifier'
end
