class CreateLectureDiscussions < ActiveRecord::Migration
  def change
    create_table :lecture_discussions do |t|
      t.belongs_to :klass, index: true
      t.belongs_to :forum, index: true
      t.belongs_to :topic, index: true
      t.belongs_to :lecture, index: true
      t.boolean :active

      t.timestamps null: false
    end

    add_foreign_key :lecture_discussions, :klasses
    add_foreign_key :lecture_discussions, :forums
    add_foreign_key :lecture_discussions, :topics
    add_foreign_key :lecture_discussions, :lectures
  end
end
