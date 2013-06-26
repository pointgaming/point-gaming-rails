source 'https://rubygems.org'

gem 'rails', '3.2.13'

gem 'resque'
gem "resque-scheduler", require: "resque_scheduler"
gem 'resque-loner'
gem 'carmen'
gem 'carmen-rails'
gem 'kaminari'
gem 'rabl-rails'
gem 'oj'
gem 'remotipart', '~> 1.0'
gem 'sanitize'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'bootstrap-sass', '~> 2.3.1.0'
  gem 'coffee-rails', '~> 3.2.1'
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
gem 'capistrano'
gem 'capistrano-ext'

# required to precompile assets
gem 'twitter-bootstrap-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'

gem "point_gaming", git: "git@github.com:pointgaming/point-gaming-core.git", branch: 'master'
