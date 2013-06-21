module UserTournamentsHelper

  def status_row_class(is_completed, is_current_step = false)
    case
    when is_completed === true
      "success"
    when is_current_step === true
      "warning"
    else
      "error"
    end
  end

end
