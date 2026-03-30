class AddUserToTrainers < ActiveRecord::Migration[8.0]
  def change
    add_belongs_to :users, :trainer, foreign_key: true
  end
end
