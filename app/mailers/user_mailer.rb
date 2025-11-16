class UserMailer < ApplicationMailer
  around_action :set_user_locale

  def notify_free_spot
    @slot = params[:slot]
    @week_start = params[:week_start]

    mail to: @user.email_address, subject: t('.subject')
  end

  private

  def set_user_locale
    @user = params[:user]
    I18n.with_locale(@user.locale) do
      yield
    end
  end
end
