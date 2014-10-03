class User < ActiveRecord::Base
  validates :session_token, presence: true, length: { minimum: 10 }
  validates :name, presence: true, length: { minimum: 1 }
  validates :email, presence: true, length: { minimum: 3 }
  has_many :votes
end
