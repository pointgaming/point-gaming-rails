require 'capistrano/ext/multistage'
require "bundler/capistrano"
load 'deploy/assets'

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

set :deploy_via, :remote_cache
set :bundle_without, [:development, :test]

set :stages, ["production"]
set :default_stage, "production"

set :application, "Pointgaming"
set :repository,  "git@github.com:pointgaming/point-gaming-rails.git"

set :scm, :git
set :scm_passphrase, ""

namespace :deploy do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :bundle_gems, :roles => :app do
    run "mkdir -p #{shared_path}/bundle && ln -s #{shared_path}/bundle #{release_path}/vendor/bundle"
    run "cd #{latest_release}; bundle install --deployment --without development test"
  end

  desc "Restart God gracefully"
  task "restart_god", :roles => :app do
    god_config_path = File.join(release_path, 'config', 'resque.god')
    begin
      # Throws an exception if god is not running.
      run "cd #{release_path}; bundle exec god status && RAILS_ENV=#{rails_env} RAILS_ROOT=#{release_path} bundle exec god load #{god_config_path} && bundle exec god start resque"

      # Kill resque processes and have god restart them with the newly loaded config.
      try_killing_resque_workers
    rescue => ex
      # god is dead, workers should be as well, but who knows.
      try_killing_resque_workers

      # Start god.
      run "cd #{release_path}; RAILS_ENV=#{rails_env} bundle exec god -c #{god_config_path}"
    end
  end

  namespace :assets do
    task :update_asset_mtimes do ; end
  end
end

before 'deploy:update_code' do
  run "#{try_sudo} chown -R nobody:nogroup #{deploy_to}"
  run "#{try_sudo} /bin/chmod -R g+rw #{deploy_to}"
end

before 'deploy:restart' do
  run "#{try_sudo} chown -R nobody:nogroup #{deploy_to}"
  run "#{try_sudo} /bin/chmod -R g+rw #{deploy_to}"
end

desc "tail log files"
task :tail, :roles => :app do
  trap("INT") { puts 'Interupted'; exit 0; }
  run "tail -f #{shared_path}/log/#{rails_env}.log" do |channel, stream, data|
    puts "#{channel[:host]}: #{data}"
    break if stream == :err
  end
end

def try_killing_resque_workers
  run "pkill -3 -f resque"
rescue
  nil
end

after :"deploy:restart", :"deploy:restart_god"
