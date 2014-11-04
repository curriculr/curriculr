class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.belongs_to :account, index: true
      t.belongs_to :user
      t.text :message
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :suspended, :default => false

      t.timestamps
    end
  end
end
