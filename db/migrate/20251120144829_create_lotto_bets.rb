class CreateLottoBets < ActiveRecord::Migration[8.1]
  def change
    create_table :lotto_bets do |t|
      t.references :client, null: false, foreign_key: true
      t.references :client_wallet, null: false, foreign_key: true
      t.references :lotto_draw, null: true, foreign_key: true
      t.string :session, null: false
      t.date :draw_date, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false, default: 100.0
      t.string :status, null: false, default: "pending"
      t.string :bet_reference, null: false
      t.integer :numbers, array: true, default: []

      t.timestamps
    end
    add_index :lotto_bets, :bet_reference, unique: true
    add_index :lotto_bets, [:client_id, :draw_date, :session]
  end
end
