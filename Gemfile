source "http://rubygems.org"

gem "rails", "3.2.14"
gem "redis-store", "> 1.1.0", "< 1.1.4"

gem "carmen"
gem "carmen-rails"
gem "kaminari"
gem "oj", ">= 2.1.4"
gem "remotipart", "~> 1.0"
gem "sanitize"
gem "pg"
gem "sequel"
gem "chronic"
gem "bunny", ">= 0.9.0.pre6"
gem "mongoid", "~> 3.0.0"
gem "redis-rails"
gem "active_hash"
gem "mail"
gem "validates_email_format_of", "~> 1.5.3"
gem "devise", "~> 3.1.0"
gem "cancan"
gem "tire"
gem "stripe"
gem "workflow_on_mongoid"
gem "mongoid-paperclip", require: "mongoid_paperclip"
gem "obscenity"
gem "rack-ssl", "~> 1.3.2"
gem "uuidtools"
gem "draper", "~> 1.0"
gem "resque"
gem "resque-scheduler"
gem "resque-loner"
gem "rabl-rails"
gem "sass-rails", "~> 3.2.3"
gem "bootstrap-sass", "~> 2.3.1.0"
gem "twitter-bootstrap-rails"

group :assets do
  gem "uglifier", ">= 1.0.3"
  gem "turbo-sprockets-rails3"
end

group :development do
  gem "better_errors", ">= 0.3.2"
  gem "binding_of_caller", ">= 0.6.8"
  gem "meta_request"
  gem "quiet_assets"
  gem "byebug"
  gem "pry-rails"
end

group :test, :development do
  gem "fabrication", require: false
  gem "guard-rspec", require: false
  gem "rb-fsevent", require: RUBY_PLATFORM =~ /darwin/i ? "rb-fsevent" : false
  gem "rspec-rails", require: false
  gem "mongoid-rspec", require: false
  gem "simplecov", require: false
  gem "database_cleaner", require: false
  gem "capybara", require: false
  gem "selenium-webdriver", require: false
  gem "spring", require: false
  gem "launchy", require: false
  gem "resque_spec", require: false
end

gem "whenever", require: false
gem "god", require: false
gem "capistrano", "~> 2.15.1"
gem "capistrano-ext"

# required to precompile assets
gem "jquery-rails"
gem "jquery-ui-rails"

gem "admin", path: "engines/admin"
gem "tournaments", path: "engines/tournaments"
