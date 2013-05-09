# set :output, "/path/to/my/cron_log.log"

every 1.day, at: '12:15 am' do
  rake "subscriptions:process"
end
