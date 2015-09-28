# This migration comes from banner (originally 20140921142502)
class CreateBannerAds < ActiveRecord::Migration
  def change
    create_table :banner_ads do |t|
      t.belongs_to :account, index: true
      t.string :advertizer
      t.text :about
      t.string :scope
      t.string :size
      t.string :hpos
      t.string :vpos
      t.date :from_date
      t.date :to_date
      t.belongs_to :image, index: true
      t.string :url
      t.text :code
      t.boolean :active, :default => true
      t.boolean :by_3rd_party, :default => false

      t.timestamps null: false
    end

    add_foreign_key :banner_ads, :accounts
  end
end
