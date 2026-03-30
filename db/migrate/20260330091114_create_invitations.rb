# frozen_string_literal: true

class CreateInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :invitations do |t|
      t.references :slot, null: false, foreign_key: true
      t.string :email, null: false
      t.date :from, null: false
      t.string :name
      t.string :token, null: false
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :invitations, :token, unique: true
    add_index :invitations, [:slot_id, :email], unique: true, where: 'accepted_at IS NULL',
                                               name: 'index_invitations_on_slot_id_and_email_pending'
  end
end
