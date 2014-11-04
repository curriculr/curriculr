class CreateAdBanners < ActiveRecord::Migration
  def change
    create_table :ad_banners do |t|
      t.belongs_to :account, index: true
      t.string :advertizer
      t.text :about
      t.string :scope
      t.string :size
      t.string :hpos
      t.string :vpos
      t.date :from_date
      t.date :to_date
      t.belongs_to :medium
      t.string :url
      t.text :code
      t.boolean :active, :default => true
      t.boolean :by_3rd_party, :default => false

      t.timestamps
    end
  end
end
