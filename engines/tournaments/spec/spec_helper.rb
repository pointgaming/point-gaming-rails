ENV["RAILS_ENV"] = "test"

require File.expand_path("../../../../config/environment", __FILE__)
require "fabrication"
Dir[File.join(File.dirname(__FILE__), "fabricators", "**", "*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = "random"

  config.before(:each) do
    Mongoid.purge!
  end
end
