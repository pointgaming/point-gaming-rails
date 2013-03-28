APP_CONFIG = YAML.load_file(Rails.root.join('config', 'config.yml'))[Rails.env]
APP_CONFIG.instance_eval do
  def [](key)
    fetch(key.to_s, nil)
  end
end
