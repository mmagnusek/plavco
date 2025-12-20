class AddTrainers < ActiveRecord::Migration[8.0]
  def change
    create_table :trainers do |t|
      t.string :name

      t.timestamps
    end

    create_table :trainers_users do |t|
      t.belongs_to :trainer, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end

    add_belongs_to :slots, :trainer, foreign_key: true

    if Slot.any?
      trainer = Trainer.create!(name: 'Plavco')
      Slot.update_all(trainer_id: trainer.id)
    end

    add_belongs_to :sessions, :trainer, foreign_key: true

    change_column_null :slots, :trainer_id, false

    if User.any? && Trainer.any?
      trainer = Trainer.first
      User.all.each do |user|
        user.trainers << trainer
      end

      Session.update_all(trainer_id: trainer.id)
    end
  end
end
