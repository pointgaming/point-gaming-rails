require 'resque/tasks'

task "resque:setup" => :environment do
  require 'finalize_bets_job'
end
