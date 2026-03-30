# frozen_string_literal: true

class Invitation < ApplicationRecord
  EXPIRY = 14.days

  belongs_to :slot

  has_secure_token :token

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :from, presence: true

  scope :pending, -> { where(accepted_at: nil) }

  def pending?
    accepted_at.nil?
  end

  def expired?
    created_at < EXPIRY.ago
  end

  def usable?
    pending? && !expired?
  end

  # :accepted / :expired when the invite page should not offer signup; nil when OK.
  def invalid_for_registration_reason
    return :accepted if accepted_at.present?
    return :expired if expired?

    nil
  end
end
