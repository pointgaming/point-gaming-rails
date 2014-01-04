module HomeHelper
  def active_class_for_tab(name)
    name === (user_signed_in?? :news : :about) ? "active" : ""
  end
end
