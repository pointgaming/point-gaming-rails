class SettingsController < ApplicationController
  before_filter :authenticate_user!

  def sub_layout
    "settings"
  end

  def index
  end
end
