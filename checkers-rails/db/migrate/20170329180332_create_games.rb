class CreateGames < ActiveRecord::Migration[5.0]
  def change
    create_table :games do |t|
      t.references :white, index: true, foreign_key: { to_table: :users }
      t.references :black, index: true, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
