rails_env   = ENV['RAILS_ENV']  || "development"
rails_root  = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'

God.watch do |w|
  w.dir      = "#{rails_root}"
  w.name     = "resque_scheduler"
  w.interval = 30.seconds
  w.env      = {"RAILS_ENV"=>rails_env}
  w.start    = "bundle exec rake -f #{rails_root}/Rakefile environment resque:scheduler"
  w.log      = "#{rails_root}/log/resque_scheduler.log"
  w.err_log  = "#{rails_root}/log/resque_scheduler_error.log"

  # restart if memory gets too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.above = 350.megabytes
      c.times = 2
    end
  end

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end
