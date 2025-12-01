class CreateLottoWins < ActiveRecord::Migration[8.1]
  def change
    create_table :lotto_wins do |t|
      t.references :lotto_bet, null: false, foreign_key: true
      t.references :lotto_draw, null: false, foreign_key: true
      t.decimal :win_amount, precision: 12, scale: 2, null: false
      t.integer :matched_numbers, null: false
      t.string :status, null: false, default: "pending"
      t.datetime :credited_at

      t.timestamps
    end
  end
end
