module Admin
  class SubscriptionFeaturesController < Admin::ApplicationController
    before_filter :ensure_subscription_feature, except: [:index, :new, :create]

    respond_to :html

    def index
      @subscription_features = SubscriptionFeature.order_by(sort_order: "ASC").all
    end

    def new
      @subscription_feature = SubscriptionFeature.new
    end

    def edit
    end

    def create
      @subscription_feature = SubscriptionFeature.new(params[:subscription_feature])
      flash[:notice] = "Subscription feature successfully created." if @subscription_feature.save

      respond_with(@subscription_feature, location: admin_subscription_features_path)
    end

    def update
      flash[:notice] = "Subscription feature successfully updated." if @subscription_feature.update_attributes(params[:subscription_feature])
      respond_with(@subscription_feature, location: admin_subscription_features_path)
    end

    def destroy
      flash[:notice] = "Subscription feature successfully deleted." if @subscription_feature.destroy
      respond_with(@subscription_feature, location: admin_subscription_features_path)
    end

    protected

    def ensure_subscription_feature
      @subscription_feature = SubscriptionFeature.find(params[:id])
    end
  end
end
