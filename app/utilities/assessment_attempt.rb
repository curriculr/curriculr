class AssessmentAttempt
  def initialize(klass, student, assessment,  attempt = nil, attempt_params = {})
    @klass = klass
    @student = student
    @assessment = assessment
    @attempt = attempt
    @attempt_params = attempt_params.nil? ? {} : attempt_params
  end
  
  def build
    test = []
    points = 0
    questions = []
    attempt = Attempt.find_or_initialize_by(:klass => @klass, :student => @student, 
    :assessment_id => @assessment.id, :state => 1)
    if attempt.new_record?
      questions = @assessment.questions

      questions.each do |q|
        test << {:q => q.id, :p => q.points, :a => q.answer, :t => {}, :c => 0, :g => 0.0 }
        points += q.points
      end

      attempt.test = test
      attempt.points = points
      
      attempt.save if @student
    else
      attempt.test.each do |t|
        question = Question.find(t[:q])
        question.points = t[:p]
        questions << question
      end
    end
      
    attempt.questions = questions
    
    attempt
  end

  def is_simple_correct?(t, q)
    q.options.each do|o|
      t[:t][o.id] = @attempt_params["#{q.id}"]["#{o.id}"].strip if @attempt_params["#{q.id}"] && @attempt_params["#{q.id}"]["#{o.id}"]
      if "#{t[:a][o.id]}".downcase.strip != "#{t[:t][o.id]}".downcase.strip 
        return false
      else
        t[:c] = 1
      end
    end
  
    true
  end

  def is_pick_one_correct?(t, q)
    is_correct = true
    answer = @attempt_params["#{q.id}"] if @attempt_params["#{q.id}"]
    q.options.each do |o|
      t[:t][o.id] = (answer == o.option ? '1' : '0')
      if t[:a][o.id] != t[:t][o.id]
        is_correct = false 
      else
        t[:c] += 1
      end
    end
  
    is_correct
  end

  def is_pick_many_correct?(t, q)
    is_correct = true
    q.options.each do |o|
      answer = @attempt_params["#{q.id}"]["#{o.id}"] if @attempt_params["#{q.id}"]
      t[:t][o.id] = (answer == o.option ? '1' : '0')
      if t[:a][o.id] != t[:t][o.id]
        is_correct = false 
      else
        t[:c] += 1
      end
    end
  
    is_correct
  end

  def is_pick_2_fill_correct?(t, q)
    is_fill_correct?(t, q)
  end

  def is_fill_correct?(t, q)
    is_correct = true
    q.options.each do|o|
      t[:t][o.id] = @attempt_params["#{q.id}"]["#{o.id}"].strip if @attempt_params["#{q.id}"] && @attempt_params["#{q.id}"]["#{o.id}"]
      if "#{t[:a][o.id]}".downcase.strip != "#{t[:t][o.id]}".downcase.strip
        is_correct = false 
      else
        t[:c] += 1
      end
    end
  
    is_correct
  end

  def is_match_correct?(t, q)
    is_fill_correct?(t, q)
  end

  def is_sort_correct?(t, q)
    is_fill_correct?(t, q)
  end

  def is_underline_correct?(t, q)
    is_fill_correct?(t, q)
  end

  def grade(test)
    points = 0.0
    
    test.each do |t|
      question = Question.find(t[:q])
      @attempt.questions << question
      t[:c] = 0
      eval("is_#{question.kind}_correct?(t,question)")
      t[:g] = (t[:p] * 1.0) * (t[:c] * 1.0 / question.options_count)
      points += t[:g]
    end

    points.round(2)
  end

  def score(params, to_save = false)
    if @attempt and @attempt.state == 1
      @attempt.questions = []
      points = grade(@attempt.test)

      score = @attempt.points > 0 ? points : 0
      if @assessment.after_deadline?(@klass)
        score = score * (1.0 - (@assessment.penalty / 100.00));
      end
      @attempt.score = score.round(2)
      @attempt.state = (to_save ? 1 : 2)
      @attempt.save
    end
  end
  
  def self.is_correct?(question, attempt)
    correct = 0
    incorrect = 0
    question.answer.each do |o, a|
      unless a == '*' && question.kind == 'simple'
        t = attempt[o]
        if t && a.strip.downcase == t.strip.downcase
          correct += 1
        else
          incorrect += 1
        end
      end
    end

    if incorrect == 0
      correct == 0 ? 'neutral' : 'correct'
    else
      correct == 0 ? 'incorrect' : 'partially_correct'
    end
  end
end