$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tournaments/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tournaments"
  s.version     = Tournaments::VERSION
  s.authors     = ["Nick Kezhaya"]
  s.email       = ["nick@whitepaperclip.com"]
  s.homepage    = "http://whitepaperclip.com"
  s.summary     = "PG Tournaments"
  s.description = "PG Tournaments"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.14"
end
