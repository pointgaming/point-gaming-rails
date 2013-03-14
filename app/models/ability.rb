class Ability
  include CanCan::Ability

  # TODO: configure user default group
  def initialize(user)
    user ||= User.new

    return if user.group.nil? || user.group.permissions.nil?

    user.group.permissions.each do |permission_id|
      permission = Permission.find(permission_id)
      can *permission.ability unless permission.nil?
    end
  end
end
