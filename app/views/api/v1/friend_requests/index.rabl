object false
child(:@friend_requests) do
  attributes :_id
  condition(->(c) { @sent }) do
    glue :friend_request_user do
      attributes :username
    end
  end
  condition(->(c) { @sent.blank? }) do
    glue :user do
      attributes :username
    end
  end
end
