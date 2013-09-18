attributes :_id
child(:user) { attributes :_id, :username }
child(:friend_request_user) { attributes :_id, :username }
