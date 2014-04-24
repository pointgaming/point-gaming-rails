module StatusHelper
  def class_name_for_status_step(step)
    case
    when step_completed?(step)
      "success"
    when current_step?(step)
      "warning"
    else
      "error"
    end
  end

  def step_completed?(step)
    return true if @tournament.activated?
    steps = @tournament.status_steps
    steps.index(step) < steps.index(@tournament.current_state.name)
  rescue
    false
  end

  def current_step?(step)
    step == @tournament.current_state.name
  end

  def step_name(step)
    I18n.t "tournament.status_steps.#{step}"
  end
end
