class Admin::SubscriptionFeaturesController < Admin::ApplicationController
  before_filter :ensure_subscription_feature, except: [:index, :new, :create]
  authorize_resource

  respond_to :html, :json

  def sub_layout
    "admin"
  end

  def index
    @subscription_features = SubscriptionFeature.order_by(:sort_order => 'ASC').all
    respond_with(@subscription_features)
  end

  def new
    @subscription_feature = SubscriptionFeature.new
    respond_with(@subscription_feature)
  end

  def edit
    respond_with(@subscription_feature)
  end

  def create
    @subscription_feature = SubscriptionFeature.new(params[:subscription_feature])
    @subscription_feature.save
    respond_with(@subscription_feature, location: admin_subscription_features_path)
  end

  def update
    @subscription_feature.update_attributes(params[:subscription_feature])
    respond_with(@subscription_feature, location: admin_subscription_features_path)
  end

  def destroy
    @subscription_feature.destroy
    respond_with(@subscription_feature, location: admin_subscription_features_path)
  end

protected

  def ensure_subscription_feature
    @subscription_feature = SubscriptionFeature.find params[:id]
  end

end
