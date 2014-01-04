module Betting
  class Better
    include Mongoid::Document
    embedded_in :bet

    field :name, :type => String
    belongs_to :user, :foreign_key => '_id'
    belongs_to :team

    validates :name, :presence=>true
    validates :user, :presence=>true
    validates :team, :presence=>true

    before_validation :populate_name, :on => :create

    def as_json(options={})
      super({
        attributes: [:_id, :name, :team_id]
      }.merge(options))
    end    

    private

      def populate_name
      	self.name = user.username if user
      end
  end
end