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
      t.string :event, :default => 'on-demand'
      t.string :kind
      t.string :to, :default => 'students'
      t.string :subject
      t.text :body
      t.integer :frequency, :default => 0
      t.boolean :made, :default => false
      t.datetime :made_at
      t.boolean :cancelled, :default => false
      t.datetime :cancelled_at
      t.timestamps
    end
  end
end
