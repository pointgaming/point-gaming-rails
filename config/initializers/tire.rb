rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

tire_config = YAML.load_file(rails_root + '/config/tire.yml')[rails_env]

Tire.configure do |config|
  config.url tire_config['url']
end
