class Account < ActiveRecord::Base
  belongs_to :user

  has_many :announcements, :dependent => :destroy
  has_many :courses, :dependent => :destroy
  has_many :media, :dependent => :destroy
  has_many :users, :dependent => :destroy

  accepts_nested_attributes_for :user

	attr_accessor :config, :settings

	validates :slug, :presence => true, :length => {:maximum => 100 }
  validates :slug, uniqueness: true
  validates :name, :about, :presence => true

  def self.current_id=(id)
    Thread.current[:account_id] = id
  end

  def self.current_id
    Thread.current[:account_id]
  end

  def config
    unless @config
      @config = JSON.parse($redis.get("config.account.a#{self.id}"))
    end

    @config
  end

  # Callback
  after_create do |account|
    account.user.skip_confirmation!
    account.user.update(account: account);
    account.user.add_role :admin

    # Create about, mission, privacy, help and agreement pages
    I18n.t('config.auto_generated_pages').each do |slug, name| 
      $site['supported_locales'].keys.each do |locale|
        page = Page.create(
          :name => name, 
          :about => I18n.t("page.text.under_construction"), 
          :public => true,
          :published => true,
          :owner => account.user,
          :slug => "#{slug}-#{locale}",
          :account => account
        )
      end
    end
  end
end
