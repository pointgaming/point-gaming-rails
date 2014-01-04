class DisputeActions
  include PointGamingRailsUrlHelper

  attr_accessor :user, :dispute

  def initialize(user, dispute)
    @user = user
    @dispute = dispute
  end

  def actions
    actions = {}
    actions[:View] = dispute_url(dispute)
    actions
  end

end
