class Game < ApplicationRecord
  belongs_to :white, class_name: :User
  belongs_to :black, class_name: :User
  has_many :moves
end
