# Preview all emails at http://localhost:3000/rails/mailers/passwords_mailer
class PasswordsMailerPreview < ActionMailer::Preview
  def reset
    user = FactoryBot.build(:user)
    PasswordsMailer.reset(user)
  end
end
