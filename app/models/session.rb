class Session < ApplicationRecord
  belongs_to :user
  belongs_to :trainer, optional: true
end
