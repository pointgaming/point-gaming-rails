module ModelActionsFactory
  class NoActions
    def actions
      {}
    end
  end

  def self.new(user, model)
    actions_class(model).constantize.new(user, model)
  rescue NameError => e
    NoActions.new
  end

  private

    def self.actions_class(model)
      "#{model.class.name}Actions"
    end

end
