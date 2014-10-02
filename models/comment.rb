class Comment < ActiveRecord::Base
  belongs_to :poll
  validates :comment, presence: true, length: { minimum: 1 }
end
