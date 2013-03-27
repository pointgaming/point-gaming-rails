DeviseController.class_eval do
  before_filter :hide_nav

private

  def hide_nav
    @hide_nav = true
  end
end
