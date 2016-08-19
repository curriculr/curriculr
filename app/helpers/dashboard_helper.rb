module DashboardHelper
	def ui_chart(name, type, data, options, height = 500)
    render :partial => "application/ui_chart",
           :locals => { :name => name, :type => type, :data => data, :options => options, :height => height }
  end

  # Course Dashboard
  def dashboard_course_activity_counts(course)
    counts = [
      [ Unit.model_name.human(:count => 3), course.units.count ],
      [ Lecture.model_name.human(:count => 3), Lecture.joins(:unit).where('units.course_id = :course_id', :course_id => course.id).count ],
      [ Medium.model_name.human(:count => 3), course.media.count ],
      [ Question.model_name.human(:count => 3), Question.where(course: course).count ],
      [ Assessment.model_name.human(:count => 3), course.assessments.count ]
    ]
    data = [['Label', 'Value']]

    max = 0
    counts.each do |c|
      data << [c[0], c[1]]
      if c[1] > max
        max = c[1]
      end
    end

    { counts: data, max: max }
  end

  def dashboard_course_medium_counts(course)
    counts = Medium.scoped.group('kind').where(course: course).count.to_a

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

  def dashboard_course_assessment_counts(course)
    counts = Assessment.group('kind').where(course: course).count.to_a

    data = [['Label', 'Value']]
    max = 0
    counts.each do |c|
      data << [c[0], c[1]]
      if c[1] > max
        max = c[1]
      end
    end

    { counts: data, max: max }
  end

  def dashboard_course_activities_by_day(since, course)
    media_by_day = course.media.where(:updated_at => since.beginning_of_day..Time.zone.now.end_of_day).
      group("date(updated_at)").select("date(updated_at) as day, '#' as url, 'none' as content_type, count(*) as count").to_a

    questions_by_day = Question.where(:course => course, :updated_at => since.beginning_of_day..Time.zone.now.end_of_day).
      group("date(updated_at)").select("date(updated_at) as day, count(*) as count").to_a

    assessments_by_day = course.assessments.where(:updated_at => since.beginning_of_day..Time.zone.now.end_of_day).
      group("date(updated_at)").select("date(updated_at) as day, '#' as url, 'none' as content_type, count(*) as count").to_a

    names = ['medium', 'question', 'assessment']
    activities = (since.to_date..Time.zone.today).map do |date|
      data = Hash[names.map do |n| [n, 0] end]
      media = media_by_day.select { |m| m.day.to_date == date }
      media.each {|m| data['medium'] = m.count}

      questions = questions_by_day.select { |q| q.day.to_date == date }
      questions.each {|q| data['question'] = q.count}

      assessments = assessments_by_day.select { |a| a.day.to_date == date }
      assessments.each {|a| data['assessment'] = a.count}

      data
    end

    i = -1
    data = (since.to_date..Time.zone.today).map do |date|
      i += 1
      [date.strftime('%b %d'), activities[i].values].flatten
    end

    data.insert(0, ['Day', names.map do |n| t("activerecord.models.#{n}", count: 3) end].flatten)
    data
  end

  # Class Dashboard
  def dashboard_klass_activity_counts(klass)
    actions = %w(enrolled attended dropped finished started_discussion posted replied)
    counts = Activity.group('action').where(:klass_id => klass).
      where(action: actions).
      select('action, sum(times) as count').to_a

    activities = Hash[actions.map{|a| [a, 0]}]
    counts.each do |c|
      activities[c.action] = c.count
    end

    data = {
      t('page.title.enrollment') => activities['enrolled'],
      t('page.title.withdrawal') => activities['dropped'],
      t('page.title.attendance') => activities['attended'],
      t('page.title.assessment') => activities['finished'],
      t('page.title.participation') => activities['started_discussion'] + activities['posted'] + activities['replied']
    }

    { counts: data.to_a.insert(0, ['label', 'value']), max: data.values.max }
  end

  def _classified_action(action)
    case action
    when 'started', 'finished'
      'assessment'
    when 'attended', 'visited', 'attempted', 'opened'
      'attendance'
    when 'started_discussion', 'posted', 'replied'
      'participation'
    when 'enrolled', 'dropped'
      'enrollment'
    else
      action
    end
  end

  def dashboard_klass_activities_by_day(since, klass)
    activity_by_day = Activity.group('action,date(created_at)').where(:klass_id => klass).
      where(:created_at => since.beginning_of_day..Time.zone.now.end_of_day).
      select('action, sum(times) as count, date(created_at) as day').to_a

    names = %w(assessment attendance participation enrollment)
    activities = (since.to_date..Time.zone.today).map do |date|
      data = Hash[names.map do |n| [n, 0] end]
      acts = activity_by_day.select { |a| a.day.to_date == date }
      acts.each do |a|
        name = _classified_action(a.action)
        data[name] += a.count
      end

      data
    end

    i = -1
    data = (since.to_date..Time.zone.today).map do |date|
      i += 1
      [date.strftime('%b %d'), activities[i].values].flatten
    end

    data.insert(0, ['Day', names.map{|n| t("page.title.#{n}")}].flatten)
  end

  def dashboard_klass_activities(klass)
    actions =Activity.group('action').where(:klass => klass).order('action').count.keys
    activities = Activity.group('klass_id, action').where(:klass => klass).
      select('action, sum(times) as count').to_a
    data = {'' => {}}
    activities.each do |activity|
      data[''][activity.action] = activity.count
    end

    table = data.map do |klass, activities|
      [klass, activities.values].flatten
    end

    table.insert(0, ['Klass', actions.map{|a| t("config.activity.#{a}")}].flatten)
    table
  end

  # Admin Dashboard
  def dashboard_admin_activity_counts
    klasses = Klass.scoped.open.active.to_a
    counts = [
      [ t('page.title.registration'), User.scoped.count ],
      [ t('page.title.confirmation'), User.scoped.where('confirmed_at is not null').count ],
      [ t('page.title.enrollment'), Enrollment.where(klass: klasses).count ],
      [ t('page.title.withdrawal'), Enrollment.where(klass: klasses).
          where('active = FALSE and dropped_at is not null').count ],
      [ t('page.title.activity'), Activity.where(klass: klasses).count ]
    ]
    data = [['Label', 'Value']]

    max = 0
    counts.each do |c|
      data << [c[0], c[1]]
      if c[1] > max
        max = c[1]
      end
    end

    { counts: data, max: max }
  end

  def dashboard_admin_user_activities(since)
    r_users = _users_by_day(since, false)
    c_users = _users_by_day(since)
    enrollments = _enrollments_by_day(since)
    signins = _users_by_day(since, true, 'last_signin_at')

    i = -1
    data = (since.to_date..Time.zone.today).map do |date|
      i += 1
      [date.strftime('%b %d'), r_users[i], c_users[i], enrollments[i], signins[i]]
    end

    data.insert(0, ['Day',
      t('page.title.registration'),
      t('page.title.confirmation'),
      t('page.title.enrollment'),
      t('page.title.signing_in')
    ])
  end

  def dashboard_admin_user_activities_1(since)
    r_users = _users_by_day(since, false)
    c_users = _users_by_day(since)
    enrollments = _enrollments_by_day(since)
    signins = _users_by_day(since, true, 'last_signin_at')

    i = -1
    labels = ['Day']
    data = [
      [t('page.title.registration')],
      [t('page.title.confirmation')],
      [t('page.title.enrollment')],
      [t('page.title.signing_in')]
    ]

    (since.to_date..Time.zone.today).each do |date|
      i += 1
      labels << date.strftime('%b %d')
      data[0] << r_users[i]
      data[1] << c_users[i]
      data[2] << enrollments[i]
      data[3] << signins[i]
    end

    return labels, data
  end

  def dashboard_confirmations_vs_enrollments(since, x, y)
    c_users = _users_by_day(since)
    enrollments = _enrollments_by_day(since)
    i = -1
    data = (since.to_date..Time.zone.today).map do |date|
      i += 1
      [c_users[i], enrollments[i]]
    end

    data.insert(0, [x, y])
  end

  def _users_by_day(since, confirmed = true, date = 'created_at')
    users_by_day = User.scoped.where(date => since.beginning_of_day..Time.zone.now.end_of_day).
      group("date(#{date})").
      select("date(#{date}) as day, count(*) as count")

    users_by_day = users_by_day.where('confirmed_at is not null') if confirmed

    (since.to_date..Time.zone.today).map do |date|
      user = users_by_day.detect { |user| user.day.to_date == date }
      user && user.count || 0
    end
  end

  def _enrollments_by_day(since)
    enrollments_by_day = Enrollment.where(:created_at => since.beginning_of_day..Time.zone.now.end_of_day).
      group("date(created_at)").
      select("date(created_at) as day, count(*) as count")

    (since.to_date..Time.zone.today).map do |date|
      enrollment = enrollments_by_day.detect { |enrollment| enrollment.day.to_date == date }
      enrollment && enrollment.count || 0
    end
  end
end
