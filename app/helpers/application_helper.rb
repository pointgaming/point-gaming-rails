module ApplicationHelper
  def count(key)
    @counts       ||= {}
    @counts[key]  ||= 0
    @counts[key]   += 1
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
end
