class CreateAnnouncements < ActiveRecord::Migration[5.0]
  def change
    create_table :announcements do |t|
      t.belongs_to :account, index: true
      t.belongs_to :user
      t.text :message
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :suspended, :default => false

      t.timestamps null: false
    end

    add_foreign_key :announcements, :accounts
    add_foreign_key :announcements, :users
  end
end
