class HomeTabsViewModel
  attr_accessor :user

  def initialize(options = {})
    self.user = options[:user]
  end

  def active_class_for_tab(tab_name)
    tab_name === default_tab ? active_class : ''
  end

  def active_class_for_pane(pane_name)
    pane_name === default_tab ? active_class : ''
  end

  private

  def active_class
    'active'
  end

  def default_tab
    user.present? ? :news : :about
  end

end
