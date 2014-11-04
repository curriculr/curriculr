class Account < ActiveRecord::Base
	belongs_to :admin, :class_name => "User"

  has_many :announcements, :dependent => :destroy
  has_many :courses, :dependent => :destroy
  has_many :media, :dependent => :destroy
  has_many :users, :dependent => :destroy

  accepts_nested_attributes_for :admin

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

  # Callback
  after_create do |account|
    account.admin.skip_confirmation!
    account.admin.update(account: account);
    account.admin.add_role :admin

    # Create about, mission, privacy, help and agreement pages
    [:mission, $site['auto_generated_pages'].keys].flatten.each do |slug| 
      $site['supported_locales'].keys.each do |locale|
        page = Page.create(
          :name => I18n.t("page.titles.#{slug}", :default => $site['auto_generated_pages'][slug]), 
          :about => I18n.t("page.text.under_construction"), 
          :public => true,
          :published => true,
          :owner => account.admin,
          :slug => "#{slug}-#{locale}",
          :account => account
        )
      end
    end
  end
end
