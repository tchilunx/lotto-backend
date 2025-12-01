class CreateServiceImoneyDrafts < ActiveRecord::Migration[8.1]
  def change
    create_table :service_imoney_drafts do |t|
      t.references :client, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :phone_number, null: false
      t.jsonb :draft_data, default: {}

      t.timestamps
    end
  end
end
