class Course < ActiveRecord::Base
  include Scopeable
  include WithMaterials
  extend FriendlyId
  
  friendly_id :name, use: [ :slugged, :finders ]
  
  acts_as_taggable_on :tags, :levels, :categories, :schools
  
  resourcify
  
  belongs_to :originator, :class_name => "User"
  has_many :instructors, :dependent => :destroy
  has_many :media, :dependent => :destroy
  has_many :pages, :dependent => :destroy, :as => :owner
  has_many :units, :dependent => :destroy
  has_many :assessments, :dependent => :destroy
  has_many :klasses, :dependent => :destroy

  attr_accessor :config, :settings
  
  
	# Validation Rules
	validates :slug, :name, :presence => true, :length => {:maximum => 100 }
  validates :slug, uniqueness: { :scope => :account_id }
  validates_format_of :slug, :with => /\A[[[:alnum:]]\-_]+\Z/i, :message => :invalid_slug
	validates :about, :weeks, :workload, :locale, :presence => true
	validates :weeks, :workload, :numericality => {:only_integer => true, :greater_than => 0 }

  def course; self; end
  
  scope :for_user_with_roles, ->(user, roles) {
    joins('left outer join instructors on courses.id = instructors.course_id').
    where("originator_id = :user_id or (role in (:roles) and instructors.user_id = :user_id)", 
      roles: roles, user_id: user.id).distinct
  }
  
  def config
    if @config.blank?
      @config = JSON.parse($redis.get("config.course.#{Account.find(Account.current_id).slug}_#{self.id}"))
    end
    
    @config
  end
  
  def unapproved_klasses
    self.klasses.where(:approved => false)
  end

  def by_instructors
    staff = instructors.where("role <> :role", :role => 'technician').order(:order).to_a 
    if staff.blank?
      staff = [ originator.name ]
    else
      staff = staff.map do |s| s.name end
    end
    
    %(#{I18n.t('page.text.by')} #{staff.join(' , ')})
  end
  
  def syllabus
    self.pages.tagged_with('syllabus').first
  end
  
  def non_syllabus_pages(published_only = false, public_only = false )
    options = "(tags.name is null or tags.name <> 'syllabus')"
    options << " and pages.published = TRUE" if published_only
    options << " and pages.public = TRUE" if public_only
    self.pages.
      joins("left outer join taggings on taggings.taggable_id = pages.id and taggings.taggable_type = 'Page'").
      joins("left outer join tags on taggings.tag_id = tags.id").
      where(options)
  end
  
  def poster
    self.materials.where("materials.kind = 'image'").tagged_with('poster').first
  end
  
  def video
    self.materials.where("materials.kind = 'video'").tagged_with('promo').first
  end
  
  def books
    self.materials_tagged(:books, :document)
  end
  
  def revision
    self.klasses.order("COALESCE(ends_on, '2099-12-31') desc, begins_on, id desc").first 
  end
    
  # Callbacks
  after_create do |course|
    self.config = YAML.load_file("#{Rails.root}/config/config-course.yml")['course']
    $redis.set "config.course.#{Account.find(Account.current_id).slug}_#{course.id}", config.to_json
    GradeDistribution.redistribute(course, self.config)
    
    self.klasses.create(:slug => 'sec-01', :begins_on => Time.zone.today, :ends_on => (Time.zone.today + (course.weeks * 7)))
    
    syllabus = self.pages.create(:name => I18n.t('page.titles.syllabus'),
      :about => I18n.t('page.text.under_construction'), :published => true)
      
    syllabus.tag_list.add('syllabus')
    
    syllabus.save
  end
  
  after_update do |course|
    self.config = YAML.load_file("#{Rails.root}/config/config-course.yml")['course']
    GradeDistribution.redistribute(course, self.config)
  end
  
end
