class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.belongs_to :account, index: true
      t.string :provider, default: 'identity'
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :uid
      t.string :avatar

      t.boolean :active, :default => true
      t.integer :pages_count, :default => 0
      t.string :time_zone

      # Remember me
      t.string :remember_token
      t.datetime :remember_created_at

      # Reset password
      t.string   :password_reset_token
      t.datetime :password_reset_sent_at

      # Confirm email
      t.string   :confirmation_token
      t.datetime :confirmation_sent_at
      t.datetime :confirmed_at
      t.string   :unconfirmed_email

      # Tracked activities
      t.integer  :signin_count, :default => 0
      t.datetime :current_signin_at
      t.string   :current_signin_ip
      t.datetime :last_signin_at
      t.string   :last_signin_ip

      t.timestamps
    end

    add_index :users, [ :email, :account_id ], :unique => true
    add_index :users, :remember_token, :unique => true
    add_index :users, :password_reset_token, :unique => true
    add_index :users, :confirmation_token, :unique => true
    # add_index :users, :unlock_token,         :unique => true
    # add_index :users, :authentication_token, :unique => true

    add_foreign_key :users, :accounts
  end
end
