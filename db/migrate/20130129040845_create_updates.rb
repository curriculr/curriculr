class CreateUpdates < ActiveRecord::Migration
  def change
    create_table :updates do |t|
      t.belongs_to :course, index: true
      t.belongs_to :unit, index: true
      t.belongs_to :lecture, index: true
      t.belongs_to :klass, index: true
      t.boolean :www, :default => true
      t.boolean :email, :default => false
      t.boolean :sms, :default => false
      t.boolean :twitter, :default => false
      t.boolean :facebook, :default => false
      t.string :to, :default => 'students'
      t.string :subject
      t.text :body
      t.boolean :active, :default => false
      t.datetime :sent_at
      t.datetime :cancelled_at
      t.integer :generator_id
      t.timestamps null: false
    end

    add_foreign_key :updates, :courses
    add_foreign_key :updates, :units
    add_foreign_key :updates, :lectures
    add_foreign_key :updates, :klasses
  end
end
