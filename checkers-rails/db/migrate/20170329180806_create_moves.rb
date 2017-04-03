class CreateMoves < ActiveRecord::Migration[5.0]
  def change
    create_table :moves do |t|
      t.text :board
      t.boolean :white_move
      t.references :game, foreign_key: true

      t.timestamps
    end
  end
end
