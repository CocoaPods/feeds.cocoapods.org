module CocoaPodsNotifier
  require 'cocoapods-core'
  Pod = ::Pod

  # Only to silence the deprecation warning.
  require 'i18n'
  I18n.enforce_available_locales = false

  require 'cocoapods_notifier/statistics'
  require 'cocoapods_notifier/github'
  require 'cocoapods_notifier/repo'
  require 'cocoapods_notifier/rss'
  require 'cocoapods_notifier/twitter_notifier'
end
