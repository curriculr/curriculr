class CreateAssessments < ActiveRecord::Migration
  def change
    create_table :assessments do |t|
      t.belongs_to :course, :index => true
      t.belongs_to :unit, :index => true
      t.belongs_to :lecture, :index => true
      t.string :kind
      t.string :name, :null => false
      t.text :about
      t.integer :questions_count, :default => 0
      t.integer :q_selectors_count, :default => 0
      t.integer :allowed_attempts, :default => 1
      t.integer :droppable_attempts, :default => 0
      t.string :multiattempt_grading, :default => 'highest'
      t.string :show_answer, :default => 'after_deadline'
      t.datetime :from_datetime
      t.datetime :to_datetime
      t.date :based_on
      t.boolean :after_deadline, :default => false
      t.integer :penalty, :default => 0
      t.integer :points, :default => 0
      t.belongs_to :invideo
      t.integer :invideo_at
      t.boolean :ready, :default => false
      t.integer :order, :default => 0
      
      t.timestamps
    end
  end
end

