namespace :subscriptions do

  task "process" => :environment do
    Subscription.pending_processing.all.each do |subscription|
      subscription.process!
    end
  end

end
