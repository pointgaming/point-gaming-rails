module Features
  module SessionHelpers

    def sign_in(user)
      login_as(user, :scope => :user)
    end

    def long_sign_in(username, password)
      visit '/users/sign_in'
      fill_in 'Username', with: username
      fill_in 'Password', with: password
      click_button 'Sign in'
    end

  end
end
