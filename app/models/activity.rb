class Activity < ActiveRecord::Base
  belongs_to :student
  belongs_to :klass
  belongs_to :context, :polymorphic => true
  belongs_to :actionable, :polymorphic => true
  
  serialize :data 
  
  scope :aggregated_for_all, ->(action, klass_id){
    action_clause = case action
    when Array
      "and action in (#{action.map {|a| "'#{a}'" }.join(',')})"
    else
      "and action = '#{action}'"
    end
    
    joins(%( inner join (
        SELECT klass_id, student_id, count(action) as acount, sum(times) as atimes
        FROM activities a
        WHERE klass_id = #{klass_id} #{action_clause}
        GROUP BY klass_id, student_id
      ) ag on activities.klass_id = ag.klass_id
    )).
    where(:klass_id => klass_id, :action => action).
    select('activities.klass_id, avg(ag.acount) as count, avg(ag.atimes) as times').
    group('activities.klass_id')
  }
  
  scope :aggregated_for_one, ->(action, klass_id, student_id){
    select('activities.klass_id, student_id, action, count(action) as count, sum(times) as times').
    group('activities.klass_id, student_id, action').
    where('activities.klass_id = :klass_id', :klass_id => klass_id).where(:student_id => student_id, :action => action)
  }
end
