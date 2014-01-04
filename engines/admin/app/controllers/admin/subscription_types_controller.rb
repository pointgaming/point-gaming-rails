module Admin
  class SubscriptionTypesController < Admin::ApplicationController
    before_filter :ensure_subscription_type, except: [:index, :new, :create]
    before_filter :ensure_subscription_features, only: [:new, :create, :edit, :update]

    respond_to :html

    def index
      @subscription_types = SubscriptionType.order_by(sort_order: "ASC").all
      respond_with(@subscription_types)
    end

    def new
      @subscription_type = SubscriptionType.new
      respond_with(@subscription_type)
    end

    def edit
      respond_with(@subscription_type)
    end

    def create
      @subscription_type = SubscriptionType.new(params[:subscription_type])
      flash[:notice] = "Subscription type successfully created." if @subscription_type.save
      respond_with(@subscription_type, location: admin_subscription_types_path)
    end

    def update
      flash[:notice] = "Subscription type successfully updated." if @subscription_type.update_attributes(params[:subscription_type])
      respond_with(@subscription_type, location: admin_subscription_types_path)
    end

    def destroy
      flash[:notice] = "Subscription type successfully deleted." if @subscription_type.destroy
      respond_with(@subscription_type, location: admin_subscription_types_path)
    end

    protected

    def ensure_subscription_type
      @subscription_type = SubscriptionType.find params[:id]
    end

    def ensure_subscription_features
      @subscription_features = SubscriptionFeature.order_by(sort_order: :asc).all
    end
  end
end
