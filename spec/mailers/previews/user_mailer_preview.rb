# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def notify_free_spot
    user = FactoryBot.build(:user, locale: params[:locale])
    slot = FactoryBot.build(:slot)
    week_start = Date.current.beginning_of_week
    UserMailer.with(user:, slot:, week_start:).notify_free_spot
  end
end
