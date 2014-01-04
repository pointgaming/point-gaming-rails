require 'bunny'
require 'mongoid'
require 'redis-rails'
require 'active_hash'
require 'mail'
require 'validates_email_format_of'
require 'devise'
require 'cancan'
require 'pundit'
require 'tire'
require 'stripe'
require 'workflow_on_mongoid'
require 'mongoid_paperclip'
require 'obscenity'
require 'uuidtools'
require 'draper'
require 'resque'
require 'resque_scheduler'
require 'resque-loner'
require 'rabl-rails'

require 'tire/model/custom_callbacks'

require 'point_gaming/engine'

module PointGaming

  def self.views_path
      File.expand_path("../app/views", File.dirname(__FILE__))
  end

end
