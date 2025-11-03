module SystemAuthentication
  def sign_in_as(user, password: '#password123#')
    visit new_session_path
    fill_in 'Email', with: user.email_address
    fill_in 'Password', with: password
    click_button 'Sign in'
  end

  def wait_for_turbo(timeout = nil)
    if has_css?('.turbo-progress-bar', visible: true, wait: (0.25).seconds)
      has_no_css?('.turbo-progress-bar', wait: timeout.presence || 5.seconds)
    end
  end

  def wait_for_turbo_frame(selector = 'turbo-frame', timeout = nil)
    if has_selector?("#{selector}[busy]", visible: true, wait: (0.25).seconds)
      has_no_selector?("#{selector}[busy]", wait: timeout.presence || 5.seconds)
    end
  end
end
