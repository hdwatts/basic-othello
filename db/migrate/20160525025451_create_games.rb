class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :score_p1
      t.integer :score_p2
      t.integer :turn
      t.text :game_board

      t.timestamps null: false
    end
  end
end
