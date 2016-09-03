class LectureDiscussion < ActiveRecord::Base
  belongs_to :klass
  belongs_to :forum
  belongs_to :topic, dependent: :destroy
  belongs_to :lecture
end
