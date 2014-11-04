require 'faker' 

FactoryGirl.define do 
  # User management
  factory :account do
    admin {
      u = User.new(name: 'Account Admin', email: 'admin@bar.com', password: 'secretive', password_confirmation: 'secretive')
      u.skip_confirmation!
      u.save
      u.add_role(:admin) 
      u
    }
    
    sequence(:slug) { |n| "#{Faker::Lorem.word}-#{n}" }
    name { Faker::Lorem.word }
	  about { Faker::Lorem.paragraphs(3).join("\n") } 
    active true
    live true
    live_since Time.zone.now
  end
  
  factory :user do
    account { $account }
    sequence(:name) { |n| "Foo #{n} Bar" } 
    sequence(:email) { |n| "foo#{n}@bar.com" } 
    password { 'secretive' }
    password_confirmation { "#{password}" }
    
    before(:create) {|user| user.skip_confirmation! }
    
    before(:build) {|user| 
      create(:access_token, user: user) if user.has_role? :console
    }
    
    factory :admin do 
      after(:create) { |user| user.add_role(:admin) }
    end
    
    factory :faculty do
      after(:create) { |user| user.add_role(:faculty) }
    end
    
    factory :team do
      after(:create) { |user| user.add_role(:team) }
    end
    
    factory :console do
      after(:create) { |user| user.add_role(:console) }
    end
  end 
  
  factory :access_token do
    association :user
    token { Faker::Lorem.word }
  end
  
  factory :instructor do
    association :user
    association :course
    email { user.email }
  end

  factory :student do
    association :user
    relationship 'self'
  end
  
  # Course management
  factory :course do
    account { $account }
    association :originator, :factory => :faculty
    sequence(:slug) { |n| "#{Faker::Lorem.word}-#{n}" }
    name { Faker::Lorem.words(3).join(' ') }
	  about { Faker::Lorem.paragraphs(3).join("\n") } 
    locale { :en }
    country { :ye }
    weeks 10
    workload 6
  end
  
  factory :unit do
    association :course
    name { Faker::Lorem.words(4).join(' ') } 
    about { Faker::Lorem.paragraphs(3).join("\n") } 
    on_date { Time.zone.today }
    based_on { Time.zone.today }
    for_days 60
  end
  
  factory :lecture do
    association :unit
    name { Faker::Lorem.words(4).join(' ') } 
    about { Faker::Lorem.paragraphs(3).join("\n") } 
    on_date { Time.zone.today }
    based_on { Time.zone.today }
    for_days 60
  end
  
  factory :medium do
    association :course
    name { Faker::Lorem.words(4).join(' ') }
    kind { :other }
    url { 'http://www.google.com' }
    
    factory :video_medium do
      kind {:video }
      path { File.new("#{Rails.root}/spec/factories/attachments/video.mp4") }
      url { nil }
    end
    
    factory :audio_medium do
      kind {:audio }
      path { File.new("#{Rails.root}/spec/factories/attachments/audio.mp3") }
      url { nil }
    end
    
    factory :image_medium do
      kind {:image }
      path { File.new("#{Rails.root}/spec/factories/attachments/image.png") }
      url { nil }
    end
    
    factory :document_medium do
      kind {:document }
      path { File.new("#{Rails.root}/spec/factories/attachments/document.pdf") }
      url { nil }
    end
    
    factory :other_medium do
      kind {:other }
      path { File.new("#{Rails.root}/spec/factories/attachments/other.txt") }
      url { nil }
    end
  end

  factory :material do
    association :medium
    kind { Faker::Lorem.word } 
    #after(:create, :build) {|material| 
    #  material.kind = material.medium.kind
    #}
  end

  # Questions and assessments
  factory :question do
    association :course
    association :unit
    association :lecture
    question { Faker::Lorem.words(12).join(' ') } 
    hint { Faker::Lorem.words(8).join(' ') } 
    explanation { Faker::Lorem.paragraphs(1).join("\n") } 
    bank_list { 'main' }

    factory :simple_question do
      kind :simple
      after(:build) {|q| 
        q.options << Option.new(:answer => Faker::Lorem.word)
      }
    end
    
    factory :fill_question do
      kind :fill
      after(:build) {|q| 
        q.options << Option.new(:option => Faker::Lorem.words(3).join(' '), :answer => Faker::Lorem.word)
        q.options << Option.new(:option => Faker::Lorem.words(3).join(' '), :answer => Faker::Lorem.word)
      }
    end
    
    factory :pick_2_fill_question do
      kind :pick_2_fill
      after(:build) {|q| 
        ao = Faker::Lorem.words(3)
        q.options << Option.new(option: Faker::Lorem.words(3).join(' '), answer: ao[0], answer_options: ao.join(','))
        q.options << Option.new(option: Faker::Lorem.words(3).join(' '), answer: ao[2], answer_options: ao.join(','))
        q.options << Option.new(option: Faker::Lorem.words(3).join(' '), answer: ao[1], answer_options: ao.join(','))
      }
    end
    
    factory :pick_one_question do
      kind :pick_one
      after(:build) {|q| 
        q.options << Option.new(option: Faker::Lorem.words(3).join(' '), answer: '0')
        q.options << Option.new(option: Faker::Lorem.words(3).join(' '), answer: '0')
        q.options << Option.new(option: Faker::Lorem.words(3).join(' '), answer: '1')
      }
    end
    
    factory :pick_many_question do
      kind :pick_many
      after(:build) {|q| 
        q.options << Option.new(option: Faker::Lorem.words(3).join(' '), answer: '1')
        q.options << Option.new(option: Faker::Lorem.words(3).join(' '), answer: '0')
        q.options << Option.new(option: Faker::Lorem.words(3).join(' '), answer: '1')
        q.options << Option.new(option: Faker::Lorem.words(3).join(' '), answer: '0')
      }
    end
    
    factory :match_question do
      kind :match
      after(:build) {|q| 
        q.options << Option.new(:option => Faker::Lorem.words(2).join(' '), :answer => Faker::Lorem.word)
        q.options << Option.new(:option => Faker::Lorem.words(2).join(' '), :answer => Faker::Lorem.word)
        q.options << Option.new(:option => Faker::Lorem.words(2).join(' '), :answer => Faker::Lorem.word)
      }
    end
    
    factory :underline_question do
      kind :underline
      after(:build) {|q| 
        o = Faker::Lorem.words(3)
        q.options << Option.new(:option => o.join(' '), :answer => o[1])
        q.options << Option.new(:option => o.join(' '), :answer => o[2])
        q.options << Option.new(:option => o.join(' '), :answer => o[0])
      }
    end
    
    factory :sort_question do
      kind :sort
      after(:build) {|q| 
        q.options << Option.new(:option => Faker::Lorem.words(3).join(' '), :answer => '1')
        q.options << Option.new(:option => Faker::Lorem.words(2).join(' '), :answer => '2')
        q.options << Option.new(:option => Faker::Lorem.words(3).join(' '), :answer => '3')
      }
    end
  end
  
  factory :assessment do
    association :course
    association :unit
    association :lecture
    kind {'quiz'}
    name { Faker::Lorem.words(3).join(' ') } 
    about { Faker::Lorem.paragraphs(3).join("\n") } 
    based_on { Time.zone.today }
    from_datetime { Time.zone.now }
    to_datetime  { 10.days.from_now }
    allowed_attempts 10
    droppable_attempts 2
    multiattempt_grading 'highest'
    show_answer 'after_deadline'
    after_deadline false
    penalty 0
    invideo_id nil
    invideo_at nil
    ready true
  end
  
  factory :attempt do
    association :klass
    association :student
    association :assessment
  end

  # Klasses and stuff
  factory :klass do
    account { $account }
    association :course
    sequence(:slug) { |n| "#{Faker::Lorem.word}-#{n}" }
    begins_on { Time.zone.today }
    approved true
    ends_on {40.days.from_now}
  end

  
  factory :enrollment do
    association :klass
    association :user
  end
    
  factory :update do
    association :course
    association :unit
    association :lecture
    association :klass
    www true
    email true
    subject { Faker::Lorem.words(5).join("\n") } 
    body { Faker::Lorem.paragraphs(1).join("\n") } 
  end
  
  factory :forum do
    association :klass
    name { Faker::Lorem.words(3).join(' ') } 
    about { Faker::Lorem.paragraphs(2).join("\n") } 
  end
  
  factory :topic do
    association :forum
    association :author, factory: :user
    name { Faker::Lorem.words(4).join(' ') } 
    about { Faker::Lorem.paragraphs(3).join("\n") } 
  end
  
  factory :post do
    association :forum
    association :topic
    association :author, factory: :user
    about { Faker::Lorem.paragraphs(2).join("\n") } 
    parent nil
  end

  factory :announcement do
    message "MyText"
    starts_at "2014-06-11 19:45:04"
    ends_at "2014-06-11 19:45:04"
    suspended false
  end
end