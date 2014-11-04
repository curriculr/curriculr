class CreateLectureDiscussions < ActiveRecord::Migration
  def change
    create_table :lecture_discussions do |t|
      t.belongs_to :klass, index: true
      t.belongs_to :forum, index: true
      t.belongs_to :topic, index: true
      t.belongs_to :lecture, index: true
      t.boolean :active

      t.timestamps
    end
  end
end
