class Permission < ActiveHash::Base
  self.data = [
    {id: :show_admin_link, ability: [:show, :admin_link]},
    {id: :manage_news, ability: [:manage, News]},
    {id: :manage_groups, ability: [:manage, Group]}
  ]
end
