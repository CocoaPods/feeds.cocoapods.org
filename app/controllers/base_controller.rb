require 'app/controllers'
require 'app/models'
require 'sinatra/base'
require 'sinatra/support/i18nsupport'
require 'dotenv'
Dotenv.load

module FeedsApp
  module Controllers
    class BaseController < Sinatra::Base
      # The base configuration for all controllers
      #
      configure do
        set :root, ROOT
        set :views, 'app/views'
        set :default_locale, 'en'

        enable :static
        enable :logging

        register Sinatra::I18nSupport
        I18n.enforce_available_locales = false
      end

      # The production configuration for all controllers
      #
      configure :production do
        use Rack::Deflater
      end

      # The development configuration for all controllers
      #
      configure :development do
        require 'better_errors'
        use BetterErrors::Middleware
        BetterErrors.application_root = ROOT

        require 'sass/plugin/rack'
        use Sass::Plugin::Rack
        Sass::Plugin.options.merge!(
          cache_location: './tmp/sass-cache',
          template_location: './public',
          css_location: './public',
        )
      end
    end
  end
end
