class User < ApplicationRecord
  has_many :bookings, dependent: :destroy
  has_many :slots, through: :bookings
  has_many :attendances, dependent: :destroy
  has_many :regular_slots, through: :attendances, source: :slot

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, format: { with: /\A[\+]?[1-9][\d]{0,15}\z/ }

  def full_name
    name
  end

  def active_bookings
    bookings.joins(:slot).where('slots.starts_at > ?', Time.current)
  end
end
