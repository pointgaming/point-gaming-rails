class DisputeMessage
  include Mongoid::Document
  include Mongoid::Timestamps

  after_create :increment_message_count
  after_destroy :decrement_message_count

  field :text, :type => String

  validates :text, :presence=>true
  validates :user, :presence=>true
  validates :dispute, :presence=>true

  belongs_to :user
  belongs_to :dispute

  def self.model_name
    ActiveModel::Name.new(self, nil, "Message")
  end

private

  def increment_message_count
    self.dispute.inc :message_count, 1
  end

  def decrement_message_count
    self.dispute.inc :message_count, -1
  end

end
