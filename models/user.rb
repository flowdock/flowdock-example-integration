class User < ActiveRecord::Base
  validates :name, presence: true, length: { minimum: 1 }
  validates :flowdock_user_id, presence: true
  has_many :votes
end
