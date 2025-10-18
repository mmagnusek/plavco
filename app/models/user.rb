class User < ApplicationRecord
  has_many :bookings, dependent: :destroy
  has_many :slots, through: :bookings
  has_many :regular_attendees, dependent: :destroy
  has_many :regular_slots, through: :regular_attendees, source: :slot
  has_many :cancellations, dependent: :destroy

  has_secure_password
  has_many :sessions, dependent: :destroy
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, format: { with: /\A[\+]?[1-9][\d]{0,15}\z/ }, allow_blank: true

  def self.create_from_oauth(auth)
    create!(
      name: auth.info.name,
      email_address: auth.info.email,
      password: SecureRandom.hex(10)
    )
  end

  def full_name
    name
  end

  def active_bookings
    bookings.joins(:slot).where('slots.starts_at > ?', Time.current)
  end
end
