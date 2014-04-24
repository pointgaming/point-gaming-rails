class Ability
  include CanCan::Ability

  # TODO: configure user default group
  def initialize(user)
    user ||= User.new

    unless user.group.nil? || user.group.permissions.nil?
      user.group.permissions.each do |permission_id|
        begin
          permission = Permission.find(permission_id)
          can *permission.ability unless permission.nil?
        rescue ActiveHash::RecordNotFound
          # no big deal
        end
      end
    end

    Permission.where(default: true).each do |permission|
      # FIXME: we should be able to make this more flexible by passing a lambda
      # instead of the hard-coded permission_check
      if permission.check_owner.present?
        permission_check = {}
        permission_check[permission.check_owner] = user._id

        can *permission.ability, permission_check
      else
        can *permission.ability
      end
    end

    # Tournament-specific permissions
    alias_action :create, :read, :update, :destroy, to: :crud

    can :join, Tournament do |tournament|
      tournament.activated? && (!(tournament.owner == user || tournament.collaborators.include?(user.id.to_s))) && tournament.signup_open? && !tournament.signed_up?(user) && !tournament.full?
    end

    can :crud, Tournament do |tournament|
      tournament.owner == user || tournament.collaborators.include?(user.id.to_s)
    end
  end
end
