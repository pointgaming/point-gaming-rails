$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "admin/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "admin"
  s.version     = Admin::VERSION
  s.authors     = ["Nick Kezhaya"]
  s.email       = ["nick@whitepaperclip.com"]
  s.homepage    = "http://whitepaperclip.com"
  s.summary     = "Admin for PG"
  s.description = "Admin for PG"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.14"
  s.add_dependency "redis-store", "> 1.1.0", "< 1.1.4"
  s.add_dependency "capistrano"
  s.add_dependency "capistrano-ext"
  s.add_dependency "jquery-rails"

  s.add_development_dependency "better_errors", ">= 0.3.2"
  s.add_development_dependency "binding_of_caller", ">= 0.6.8"
  s.add_development_dependency "quiet_assets"
end
