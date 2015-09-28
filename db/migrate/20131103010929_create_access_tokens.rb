class CreateAccessTokens < ActiveRecord::Migration
  def change
    create_table :access_tokens do |t|
      t.belongs_to :user, index: true
      t.string :token
      t.string :scope
      t.string :ip
      t.string :country
      t.integer :expires_in
      t.datetime :revoked_at
      t.datetime :created_at
    end

    add_index :access_tokens, :token, :unique => true
    add_foreign_key :access_tokens, :users
  end
end
