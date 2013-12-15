source 'https://rubygems.org'

gem 'rails', '3.2.14'
gem 'redis-store', '> 1.1.0', '< 1.1.4'

gem 'carmen'
gem 'carmen-rails'
gem 'kaminari'
gem 'oj'
gem 'remotipart', '~> 1.0'
gem 'sanitize'
gem "pg"
gem "sequel"

group :assets do
  gem 'uglifier', '>= 1.0.3'
  gem 'turbo-sprockets-rails3'
end

group :development do
  gem "better_errors", ">= 0.3.2"
  gem "binding_of_caller", ">= 0.6.8"
  gem 'meta_request'
  gem 'quiet_assets'
end

group :test, :development do
  gem 'fabrication', require: false
  gem 'guard-rspec', require: false
  gem 'rb-fsevent', require: RUBY_PLATFORM =~ /darwin/i ? 'rb-fsevent' : false
  gem 'rspec-rails', require: false
  gem 'mongoid-rspec', require: false
  gem 'simplecov', require: false
  gem 'database_cleaner', require: false
  gem 'capybara', require: false
  gem 'selenium-webdriver', require: false
  gem 'spring', require: false
  gem 'launchy', require: false
  gem 'resque_spec', require: false
end

gem 'whenever', require: false
gem 'god', require: false
gem 'capistrano', '~> 2.15.1'
gem 'capistrano-ext'

# required to precompile assets
gem 'jquery-rails'
gem 'jquery-ui-rails'

gem "point_gaming", git: "git@github.com:pointgaming/point-gaming-core.git", branch: 'master'
gem "point_gaming_frontend", git: "git@github.com:pointgaming/point-gaming-frontend.git", branch: 'master'
