class Ability
  include CanCan::Ability

  def initialize(account, user, student = nil, course = nil, klass = nil, assessment = nil)
    user ||= User.new
    
    can [:front, :root], User
    can :hide, Announcement
    can [ :show, :localized ], Page, :published => true, :public => true
    can :blogs, Page
    can [ :search, :index ], Klass
    can :show, Klass if (klass && klass.approved)
    if klass && klass.previewed
      can :index, Lecture
      can [ :show, :show_page, :show_material ], Lecture, 
        :unit => {:previewed => true}, :previewed => true 
    end

    unless user.anonymous?
      can :sign_out, User
      can :front, User
      
      can :manage, Student, :user_id => user.id
      
      if klass 
        can :show, Klass if klass.approved
        can :enroll, Klass if klass.can_enroll?(user, student)
        can :decline, Klass if klass.invited_and_not_yet_accepted?(user)
        if klass.enrolled?(student)
          can :drop, Klass 
          can [ :index, :show, :show_page, :show_material, :show_question, :show_assessment ], Lecture
          can [ :index, :show ], [ Forum, Topic ]
          can [ :new, :create, :edit, :update, :up, :down, :destroy ], [ Topic, Post ] if klass.open?
          can [ :show, :localized, :index ], Page, :published => true
          can :index, Material
          
          can [ :show, :index ], Assessment, :ready => true
          can :new, Attempt do |attempt|
            klass.open? && assessment.can_be_taken?(klass, student)
          end
          can :create, Attempt do |attempt|
            assessment && assessment.open?(klass) && attempt.state == 1
          end
          can :show_answer, Attempt do |attempt|
            (attempt.state == 1 && attempt.show_answer?) || 
            (attempt.state == 2 && attempt.assessment.show_answer?(klass))
          end
          
          can :report, Klass
        end
      end
      
      can [ :home, :show, :edit, :update, :destroy_session, :edit_password, 
        :change_password ], User, :id => user.id
        
      if user.has_role? :faculty || ((course || klass) && KlassEnrollment.staff?(user, course || klass))
        can [ :new, :create, :index ], Course if user.has_role? :faculty

        course = klass.course if course.blank? && klass.present?
        if course
          can :manage, :all do |object|
            course.originator_id == user.id || 
            course.instructors.map(&:user_id).include?(user.id)
          end
        end

        can :manage, Page, :owner_id => user.id
      end
      
      can :manage, :all if user.id == 1

      if user.has_role? :admin and account == user.account
        can :manage, :all
      end

      if user.has_role? :console
        can :manage, AccessToken
      end
    end
  end
end
