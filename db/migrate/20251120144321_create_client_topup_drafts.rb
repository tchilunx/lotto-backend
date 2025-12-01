class CreateClientTopupDrafts < ActiveRecord::Migration[8.1]
  def change
    create_table :client_topup_drafts do |t|
      t.references :client, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :payment_method, null: false
      t.jsonb :draft_data, default: {}

      t.timestamps
    end
  end
end
