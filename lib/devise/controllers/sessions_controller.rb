Devise::SessionsController.class_eval do
  before_filter :hide_nav, only: [:new]

private

  def hide_nav
    @hide_nav = true
  end
end
