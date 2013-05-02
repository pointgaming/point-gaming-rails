class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!

  def sub_layout
    "settings"
  end

  def index
    @subscription_features = SubscriptionFeature.order_by(:sort_order => 'ASC').all
    @subscription_types = SubscriptionType.order_by(:sort_order => 'ASC').all
  end

  def new

  end

  def create

  end
end
