class CreateLottoDraws < ActiveRecord::Migration[8.1]
  def change
    create_table :lotto_draws do |t|
      t.string :session, null: false
      t.date :draw_date, null: false
      t.datetime :drawn_at
      t.string :status, null: false, default: "pending"
      t.integer :numbers, array: true, default: []

      t.timestamps
    end
    add_index :lotto_draws, [ :draw_date, :session ], unique: true
  end
end
