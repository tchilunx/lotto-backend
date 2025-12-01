# frozen_string_literal: true

class DeviseCreateClients < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      ## Authentification
      t.string :phone,              null: false
      t.string :email
      t.string :encrypted_password, null: false, default: ""

      ## Recovery
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## JWT
      t.string :jti, null: false

      ## Infos perso
      t.string :first_name
      t.string :last_name
      t.boolean :kyc_valid, default: false

      t.timestamps null: false
    end

    add_index :clients, :phone, unique: true
    add_index :clients, :jti, unique: true
  end
end
