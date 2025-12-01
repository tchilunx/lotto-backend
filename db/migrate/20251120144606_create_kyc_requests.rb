class CreateKycRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :kyc_requests do |t|
      t.references :client, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.string :document_type, null: false
      t.string :document_number, null: false
      t.string :rejection_reason

      t.timestamps
    end
  end
end
