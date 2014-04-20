module Tournaments
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework :rspec, fixture_replacement: "fabrication"
      g.fixture_replacement :fabrication, dir: "spec/fabricators"
    end
  end
end

