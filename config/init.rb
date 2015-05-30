# -- General ------------------------------------------------------------------

ROOT = File.expand_path('../../', __FILE__)
$LOAD_PATH.unshift File.join(ROOT, 'lib')

ENV['RACK_ENV'] ||= 'development'
ENV['DATABASE_URL'] ||= "postgres://localhost/trunk_cocoapods_org_#{ENV['RACK_ENV']}"

# -- Database -----------------------------------------------------------------

require 'sequel'
require 'pg'

db_loggers = []
DB = Sequel.connect(ENV['DATABASE_URL'], loggers: db_loggers)
Sequel.extension :core_extensions, :migration
