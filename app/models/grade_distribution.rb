class GradeDistribution < ActiveRecord::Base
  belongs_to :course

  def self.redistribute(course, config)
    GradeDistribution.transaction do
      GradeDistribution.where(course_id: course.id).destroy_all
      config["grading"]["distribution"].each do |k, v|
        if k == 'assessments'
          v['course'].each do |ck, cv|
            gd = GradeDistribution.where(course_id: course.id, level: :course, kind: ck).first_or_initialize
            gd.grade = cv
            gd.save
          end

          v['unit'].each do |uk, uv|
            gd = GradeDistribution.where(course_id: course.id, level: :unit, kind: uk).first_or_initialize
            gd.grade = uv
            gd.save
          end

          v['lecture'].each do |lk, lv|
            gd = GradeDistribution.where(course_id: course.id, level: :lecture, kind: lk).first_or_initialize
            gd.grade = lv
            gd.save
          end
        else
          gd = GradeDistribution.where(course_id: course.id, level: :course, kind: k).first_or_initialize
          gd.grade = v
          gd.save
        end
      end
    end
  end

  scope :final_score_report, ->(klass, student_id) {
    participation = Klass.joins(%(inner join (
        select klass_id, student_id, sum(points) as points
        from activities
        where
          actionable_type = 'Forum' and points > 0
        group by klass_id, student_id
        ) a on a.klass_id = id)).
      select("id, max(a.points) as max_points, avg(a.points) as avg_points").
      where(id: klass.id).group('id').first

    base_participation_avg = participation ? participation.avg_points : 0.0
    base_participation_max = participation ? participation.max_points : 0.0

    base_attendance = Lecture.joins(:unit).where("course_id = #{klass.course_id}").sum(:points)

    student_clause = student_id.present? ? %(and student_id = #{student_id}) : nil

    text_cast = ActiveRecord::Base.connection.adapter_name == "PostgreSQL" ? '::text' : nil
    joins(%(
      left outer join (
        select distinct
          course_id, case
            when lecture_id is null and unit_id is null then 'course'
            when lecture_id is null and unit_id is not null then 'unit'
            else 'lecture'
          end as level, kind, sum(assessments.points) as points,
          sum(t.scored) as scored
        from assessments
          left outer join (
            select klass_id, student_id, assessment_id,
              case when multiattempt_grading = 'average' then avg(score) else max(score) end as scored
            from attempts, assessments
            where attempts.assessment_id = assessments.id and
              attempts.state = 2 and
              klass_id = #{klass.id} #{student_clause}
            group by klass_id, student_id, assessment_id, multiattempt_grading
          ) t on id = t.assessment_id
        where course_id = #{klass.course_id}
        group by course_id, level, kind
      ) a on grade_distributions.course_id = a.course_id and
             grade_distributions.kind = a.kind and 
             grade_distributions.level = a.level
    )).joins(%(
      left outer join (
        select 'attendance'#{text_cast} as kind, student_id, sum(points) as points,
          #{base_attendance} as max_attendance
        from activities
        where
          activities.klass_id = #{klass.id} #{student_clause} and
          actionable_type = 'Lecture'
        group by klass_id, student_id
      ) l on grade_distributions.kind = l.kind
    )).joins(%(
      left outer join (
        select 'participation'#{text_cast} as kind, student_id, sum(points) as points,
          #{base_participation_avg} as avg_participation,
          #{base_participation_max} as max_participation
        from activities
        where
          activities.klass_id = #{klass.id} #{student_clause} and
          actionable_type = 'Forum'
        group by klass_id, student_id
      ) p on grade_distributions.kind = p.kind
    )).select(%(grade_distributions.id, grade_distributions.course_id,
      grade_distributions.level, grade_distributions.kind, grade_distributions.grade,
      coalesce(a.points, l.max_attendance, p.max_participation, 0) as max_points,
      coalesce(a.points, l.max_attendance, p.avg_participation, 0) as avg_points,
      coalesce(a.scored, l.points, p.points, 0) as scored)).
    where('grade_distributions.course_id = :course_id', course_id: klass.course_id).
    where('grade_distributions.grade > 0').
    order('p.student_id, grade_distributions.id')
  }
end
