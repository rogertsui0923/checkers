class User < ApplicationRecord
  has_secure_password

  has_many :white_games, class_name: :Game, foreign_key: :white_id
  has_many :black_games, class_name: :Game, foreign_key: :black_id

  VALID_EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: VALID_EMAIL_REGEX

end
