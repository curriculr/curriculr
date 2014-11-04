class LectureDiscussion < ActiveRecord::Base
  belongs_to :klass
  belongs_to :forum
  belongs_to :topic
  belongs_to :lecture
end
