class DisputeMessage
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Rails.application.routes.url_helpers

  after_create :publish_created
  after_create :increment_message_count
  after_destroy :decrement_message_count

  field :text, :type => String

  has_mongoid_attached_file :attachment

  validates :text, :presence=>true
  validates :user, :presence=>true
  validates :dispute, :presence=>true
  validates_attachment :attachment, :size => { :in => 0..20.megabytes }

  belongs_to :user
  belongs_to :dispute

  def self.model_name
    ActiveModel::Name.new(self, nil, "Message")
  end

  # emit messages to the dispute exchange
  delegate :mq_exchange, :to => :dispute, :allow_nil => true

  def anchor
    "message-#{_id}"
  end

  def url
    dispute_url(dispute, anchor: anchor)
  end

private

  def increment_message_count
    self.dispute.inc :message_count, 1
  end

  def decrement_message_count
    self.dispute.inc :message_count, -1
  end

  def publish_created
    BunnyClient.instance.publish_fanout("c.#{mq_exchange}", ::RablRails.render(self, 'dispute_messages/publish_created'))
  end

end
