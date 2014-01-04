APP_CONFIG = YAML.load_file(File.join(File.expand_path('../..', __FILE__), "config.yml"))[Rails.env]
APP_CONFIG.instance_eval do
  def [](key)
    fetch(key.to_s, nil)
  end
end
