if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/config/'
    add_filter '/lib/'
    add_filter '/vendor/'
  
    add_group 'Controllers', 'app/controllers'
    add_group 'Models', 'app/models'
    add_group 'Helpers', 'app/helpers'
  end
end

module Helpers
  def stub_user_sync_methods
    Store::User.any_instance.stub(:save).and_return(true)
    Store::User.any_instance.stub(:find).and_return(Store::User.new)
    ForumUser.any_instance.stub(:save).and_return(true)
    ForumUser.any_instance.stub(:find).and_return(Store::User.new)
  end

  def unstub_user_sync_methods
    Store::User.any_instance.unstub(:save)
    Store::User.any_instance.unstub(:find)
    ForumUser.any_instance.unstub(:save)
    ForumUser.any_instance.unstub(:find)
  end
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'fabrication'
require 'rspec/rails'
require 'mongoid-rspec'
require 'capybara/rails'
require 'capybara/rspec'
require 'resque_spec'
require 'resque_spec/scheduler'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include Helpers
  config.include DateHelpers
  config.include ApiTokenHelpers
  config.include Features::SessionHelpers, type: :feature
  config.include Features::FormHelpers, type: :feature
  config.include Features::JavascriptHelpers, type: :feature
  config.include Rails.application.routes.url_helpers, type: :feature

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  require 'database_cleaner'
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = "mongoid"
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end

  config.before(:each) { stub_user_sync_methods }
  config.after(:each) { unstub_user_sync_methods }
end
