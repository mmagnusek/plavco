class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, :trainer, to: :session, allow_nil: true
end
