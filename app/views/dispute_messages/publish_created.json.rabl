object false
node :action do
  'Dispute.Message.new'
end
child @object => :data do
  child @object => :dispute_message do
    extends "dispute_messages/base"
  end
end
