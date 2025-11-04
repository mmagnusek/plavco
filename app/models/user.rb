class User < ApplicationRecord
  has_many :bookings, dependent: :destroy
  has_many :slots, through: :bookings
  has_many :regular_attendees, dependent: :destroy
  has_many :regular_slots, through: :regular_attendees, source: :slot
  has_many :cancellations, dependent: :destroy
  has_many :omni_auth_identities, dependent: :destroy

  has_secure_password
  has_many :sessions, dependent: :destroy
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, format: { with: /\A[\+]?[1-9][\d]{0,15}\z/ }, allow_blank: true
  validates :phone, presence: true, if: :profile_update?
  validates :locale, inclusion: { in: I18n.available_locales.map(&:to_s) }

  def self.create_from_oauth(auth)
    create!(
      name: auth.info.name,
      email_address: auth.info.email,
      password: SecureRandom.hex(10)
    )
  end

  def complete_profile?
    phone?
  end

  def full_name
    name
  end

  def active_bookings
    bookings.joins(:slot).where('slots.starts_at > ?', Time.current)
  end

  def profile_update!
    @profile_update = true
  end

  def phone=(value)
    super(value.gsub(/[\s]/, ''))
  end

  private

  def profile_update?
    @profile_update
  end
end
