module DashboardHelper
	def ui_chart(name, type, data, options, height = 500)
    render :partial => "application/ui_chart", 
           :locals => { :name => name, :type => type, :data => data, :options => options, :height => height }
  end

  def dashboard_course_medium_counts(course)
    counts = Medium.group('kind').where(course: course).count.to_a

    data = [['Label', 'Value']]
    max = 0
    counts.each do |c|
      data << [t("config.medium.kind.#{c[0]}"), c[1]]
      if c[1] > max 
        max = c[1]
      end
    end

    { counts: data, max: max }        
  end

  def dashboard_course_question_counts(course)
    counts = Question.group('kind').where(course: course).count.to_a

    data = [['Label', 'Value']]
    max = 0
    counts.each do |c|
      data << [t("config.question.kind.#{c[0]}"), c[1]]
      if c[1] > max 
        max = c[1]
      end
    end

    { counts: data, max: max }           
  end

	def stats_student_activity(klass, student, action, aggregate= :sum)  
    one = Activity.aggregated_for_one(action, klass.id, student.id).to_a.first || { count: 0, times: 0 }
    all = Activity.aggregated_for_all(action, klass.id).to_a.first
    unless aggregate == :sum
      [['owner', 'count'], [t('config.report.average'), all ? all[:count].to_f : 0], [t('config.report.you'), one ? one[:count].to_f : 0]]    
    else
      [['owner', 'count'], [t('config.report.average'), all ? all[:times].to_f : 0], [t('config.report.you'), one ? one[:times].to_f : 0]]   
    end  
  end
  
  def stats_student_activity1(klass, student, action, aggregate= :sum)
    ecount = [ klass.enrollments.where('enrollments.active = TRUE').count * 1.0, 1.0 ].max
    
    you = Activity.where("klass_id = #{klass.id} and student_id = #{student.id}").where(:action => action)
    others = Activity.where("klass_id = #{klass.id} and student_id <> #{student.id}").where(:action => action)
    unless aggregate == :sum
      [['owner', 'count'], [t('config.report.average'), others.count / ecount], [t('config.report.you'), you.count]]    
    else
      [['owner', 'count'], [t('config.report.average'), others.sum('times') / ecount], [t('config.report.you'), you.sum('times')]]   
    end  
  end
  
  def stats_student_assessment(klass, student, kind = nil)
    all = stats_klass_attempts_by_day(klass, kind, 2)
    std = stats_klass_attempts_by_day(klass, kind, 2, student)
    i = 0
    data = all.map do |aid, avg|
      i += 1
      ["#{i}", avg, std[aid].blank? ? 0.0 : std[aid]]
    end
    
    data.insert(0, ['Assessment', t('config.report.average'), t('config.report.you')])
    data.insert(1, ['0', 0, 0])
    data
  end
  
  def stats_course_media(courses)
    klass_sql = "select * from klasses where klasses.course_id = courses.id and klasses.active = TRUE and klasses.approved = TRUE and klasses.begins_on <= :day and klasses.ends_on >= :day"
    kinds = Medium.group('kind').count.keys
    media = Course.joins(:media).group('courses.id, courses.name, media.kind').
            where(:id => courses).
            where("exists (#{klass_sql})", :day => Time.zone.now).
            select('courses.name, media.kind as kind, count(*) as count').order('courses.name, kind')
    data = {}
    media.each do |medium|
      data[medium.name] = Hash[kinds.map{|a| [a,0]}] if data[medium.name].blank?
      data[medium.name][medium.kind] = medium.count
    end
    
    table = data.map do |course, media|
      [course, media.values].flatten
    end

    table.insert(0, ['Course', kinds.map{|a| t("config.medium.kind.#{a}")}].flatten)
    table          
  end
  
  def stats_course_questions(courses)
    klass_sql = "select * from klasses where klasses.course_id = courses.id and klasses.active = TRUE and klasses.approved = TRUE and klasses.begins_on <= :day and klasses.ends_on >= :day"
    kinds = Question.group('kind').count.keys
    questions = Course.joins('inner join questions on courses.id = questions.course_id').group('courses.id, courses.name, questions.kind').
            where(:id => courses).
            where("exists (#{klass_sql})", :day => Time.zone.now).
            select('courses.name, questions.kind as kind, count(*) as count').order('courses.name, questions.kind')
    data = {}
    questions.each do |question|
      data[question.name] = Hash[kinds.map{|a| [a,0]}] if data[question.name].blank?
      data[question.name][question.kind] = question.count
    end
    
    table = data.map do |course, questions|
      [course, questions.values].flatten
    end

    table.insert(0, ['Course', kinds.map{|a| t("config.question.kind.#{a}")}].flatten)
    table          
  end
  
  def stats_klass_activities(klasses)
    actions =Activity.group('action').order('action').count.keys
    activities = Activity.group('courses.slug, klass_id, action').joins(:klass => :course).
      where(:klass_id => klasses).
      select('courses.slug, action, sum(times) as count').order('courses.slug, action')
    data = {}
    activities.each do |activity|
      data[activity.slug] = Hash[actions.map{|a| [a,0]}] if data[activity.slug].blank?
      data[activity.slug][activity.action] = activity.count
    end
    
    table = data.map do |klass, activities|
      [klass, activities.values].flatten
    end

    table.insert(0, ['Klass', actions.map{|a| t("config.activity.#{a}")}].flatten)
    table          
  end
  
  def stats_scatter_plot(since, x, y)
    c_users = stats_users_by_day(since)
    enrollments = stats_enrollments_by_day(since)
    i = -1
    data = (since.to_date..Date.today).map do |date|
      i += 1
      [c_users[i], enrollments[i]]
    end
    
    data.insert(0, [x, y])
    data
  end
  
  def stats_course_questions_by_day(since, courses)
    klass_sql = "select * from klasses where klasses.course_id = courses.id and klasses.active = TRUE and klasses.approved = TRUE and klasses.begins_on <= :day and klasses.ends_on >= :day"
    names = Course.group('name').where("exists (#{klass_sql})", :day => since).count.keys
    questions_by_day = Question.joins(:course).
      where(:course_id => courses, :created_at => since.beginning_of_day..Time.zone.now.end_of_day).
      where("exists (#{klass_sql})", :day => since).
      group("course_id, courses.name, date(questions.created_at)").select("courses.name, date(questions.created_at) as day, count(*) as count")
    
    questions = (since.to_date..Date.today).map do |date|
      data = Hash[names.map{|c| [c,0]}]
      questions = questions_by_day.select { |q| q.day.to_date == date }
      questions.each {|q| data[q.name] = q.count}
      
      data
    end
    
    i = -1
    data = (since.to_date..Date.today).map do |date|
      i += 1
      [date.strftime('%b %d'), questions[i].values].flatten
    end
    
    data.insert(0, ['Day', names].flatten)
    data
  end
  
  def stats_course_media_by_day(since, courses)
    klass_sql = "select * from klasses where klasses.course_id = courses.id and klasses.active = TRUE and klasses.approved = TRUE and klasses.begins_on <= :day and klasses.ends_on >= :day"
    names = Course.group('name').where("exists (#{klass_sql})", :day => since).count.keys
    media_by_day = Medium.joins(:course).
      where(:course_id => courses, :created_at => since.beginning_of_day..Time.zone.now.end_of_day).
      where("exists (#{klass_sql})", :day => since).
      group("course_id, courses.name, date(media.created_at)").select("courses.name, date(media.created_at) as day, '#' as url, 'none' as content_type, count(*) as count")
    
    media = (since.to_date..Date.today).map do |date|
      data = Hash[names.map{|c| [c,0]}]
      media = media_by_day.select { |m| m.day.to_date == date }
      media.each {|m| data[m.name] = m.count}
      
      data
    end
    
    i = -1
    data = (since.to_date..Date.today).map do |date|
      i += 1
      [date.strftime('%b %d'), media[i].values].flatten
    end
    
    data.insert(0, ['Day', names].flatten)
    data
  end
  
  def stats_user_activities(since)
    r_users = stats_users_by_day(since, false)
    c_users = stats_users_by_day(since)
    i = -1
    data = (since.to_date..Date.today).map do |date|
      i += 1
      [date.strftime('%b %d'), r_users[i], c_users[i]]
    end
    
    data.insert(0, ['Day', 'Registered', 'Confirmed'])
    data
  end
  
  def stats_enrollment_activities(since)
    enrollments = stats_enrollments_by_day(since)
    i = -1
    data = (since.to_date..Date.today).map do |date|
      i += 1
      [date.strftime('%b %d'), enrollments[i]]
    end
    
    data.insert(0, ['Day', 'Class Enrollments'])
    data
  end
  
  def stats_klass_attempts_by_day(klass, kind = nil, state = 2, student = nil)
    attempts_by_day = Attempt.joins(:assessment).where(:klass_id => klass.id, :state => state).
      group("assessment_id").
      select("assessment_id as aid, avg(score) as avg")
    
    attempts_by_day = attempts_by_day.where('assessments.unit_id is null and assessments.lecture_id is null') if kind == 'course'
    attempts_by_day = attempts_by_day.where('assessments.unit_id is not null and assessments.lecture_id is null') if kind == 'unit'
    attempts_by_day = attempts_by_day.where('assessments.lecture_id is not null') if kind == 'lecture'
    attempts_by_day = attempts_by_day.where(:student_id => student.id) if student
    
    Hash[attempts_by_day.map {|a| [a.aid, a.avg]}]
  end
  
  def stats_users_by_day(since, confirmed = true)
    users_by_day = User.where(:created_at => since.beginning_of_day..Time.zone.now.end_of_day).
      group("date(created_at)").
      select("date(created_at) as day, count(*) as count")
      
    users_by_day = users_by_day.where('confirmed_at is not null') if confirmed
    
    (since.to_date..Date.today).map do |date|
      user = users_by_day.detect { |user| user.day.to_date == date }
      user && user.count || 0
    end
  end
  
  def stats_enrollments_by_day(since)
    enrollments_by_day = Enrollment.where(:created_at => since.beginning_of_day..Time.zone.now.end_of_day).
      group("date(created_at)").
      select("date(created_at) as day, count(*) as count")
    
    (since.to_date..Date.today).map do |date|
      enrollment = enrollments_by_day.detect { |enrollment| enrollment.day.to_date == date }
      enrollment && enrollment.count || 0
    end
  end
end
