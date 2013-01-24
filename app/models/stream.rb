class Stream
  include Mongoid::Document

  field :name, :type => String, :default => ''
  field :details, :type => String, :default => ''
  field :betting, :type => Boolean, :default => true

  field :viewer_count, :type => Integer, :default => 0

  belongs_to :game

  validates :name, :presence=>true
  validates :details, :presence=>true
  validates :betting, :presence=>true
  validates :viewer_count, :presence=>true
end
