class OrdersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_order, :only=>[:show]

  respond_to :html, :json

  def index
    @orders = current_user.orders.all
    respond_with(@orders)
  end

  def show
    respond_with(@order)
  end

protected

  def ensure_order
    @order = current_user.orders.find(params[:id])
  end

end
