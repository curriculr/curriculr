class Page < ActiveRecord::Base
  include Scopeable
  include Actionable

  acts_as_taggable_on :tags
  
  belongs_to :owner, :polymorphic => true, :counter_cache => true  
  
	# Validation Rules
	validates :name, :about, :presence => true
  validates :slug, uniqueness: { :scope => :account_id }, if: -> { slug.present? }
  validates_format_of :slug, :with => /\A([[[:alnum:]]\-_]+)?\Z/i, :message => :invalid_slug
  
  def course
    if owner.is_a?(User)
      nil
    else
      owner.course
    end
  end
  
  default_scope -> { 
    order 'updated_at DESC'
  }
  
  scope :blogs, -> {
    scoped.where(:owner_type => 'User', :public => true, :published => true, :blog => true)
  }
  
  def by_author_and_when
    if !blog || owner_type != 'User'
      %(#{I18n.t('page.text.on')} #{I18n.l(created_at.to_date)})
    elsif owner.has_role?(:admin)
      %(#{I18n.l(created_at.to_date)})
    else
      %(#{I18n.t('page.text.by')} #{owner.name} #{I18n.t('page.text.on')} #{I18n.l(created_at.to_date)})
    end
  end

  def self.localized(slug)
    page = Page.scoped.where(slug: "#{slug}-#{I18n.locale}").first
    if page.blank?
      page = Page.scoped.find_by(slug: "#{slug}-#{I18n.default_locale}")
    end
    
    page
  end
end
