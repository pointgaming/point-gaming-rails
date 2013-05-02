class Permission < ActiveHash::Base
  self.data = [
    {id: :show_admin_link, ability: [:show, :admin_link]},
    {id: :manage_news, ability: [:manage, News]},
    {id: :manage_groups, ability: [:manage, Group]},
    {id: :manage_subscription_features, ability: [:manage, SubscriptionFeature]},
    {id: :forums_admin, ability: [:admin, :forums]},
    {id: :store_admin, ability: [:admin, :store]},

    # default abilities
    {id: :edit_news_comment, default: true, check_owner: :user_id, ability: [:edit, NewsComment]},
    {id: :destroy_news_comment, default: true, check_owner: :user_id, ability: [:destroy, NewsComment]},
  ]
end
