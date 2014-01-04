module StatusHelper
  def class_name_for_status_step(step)
    case
    when step.is_completed?
      "success"
    when step.is_current_step?
      "warning"
    else
      "error"
    end
  end
end
