shared_examples_for "requires_login" do
  it 'redirects when the user is not logged in' do
    expect(response.status).to redirect_to(new_user_session_path)
  end
end
