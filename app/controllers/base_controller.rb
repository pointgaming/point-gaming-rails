class BaseController < ActionController::Base
  protect_from_forgery

  before_filter :remove_layout_for_ajax_requests

  def remove_layout_for_ajax_requests
    self.action_has_layout = false if request.xhr?
  end

  def desktop_client_latest_version
    SiteSetting.find_by(key: 'desktop_version').value
  rescue Mongoid::Errors::DocumentNotFound
    '0.0.0'
  end

  helper_method :desktop_client_latest_version

  def current_order
    @current_order ||= get_current_order
  end

  helper_method :current_order

  private

  def get_current_order
    if session[:order_id].present?
      current_order = Store::Order.find(session[:order_id])
      current_order.completed_at.present? ? nil : current_order
    end
  rescue => e
    logger.warn "get_current_order failed: #{e.class}: #{e.message}"
    nil
  end
end
