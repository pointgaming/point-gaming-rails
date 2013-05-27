class CustomResponder < ActionController::Responder
  def json_resource_errors
    {:errors => resource.errors.full_messages}
  end

  def api_behavior(error)
    raise error unless resourceful?

    if get?
      display resource
    elsif post?
      display resource, :status => :created, :location => api_location
    else
      display resource || true
    end 
  end
end
