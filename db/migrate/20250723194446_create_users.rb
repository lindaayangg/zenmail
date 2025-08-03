class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :name
      t.string :provider
      t.string :uid
      t.string :access_token
      t.string :refresh_token
      t.datetime :token_expires_at
      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
