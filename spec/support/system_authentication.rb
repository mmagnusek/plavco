module SystemAuthentication
  def sign_in_as(user, password: 'password')
    visit new_session_path
    fill_in 'Email', with: user.email_address
    fill_in 'Password', with: password
    click_button 'Sign in'
  end
end
