class Option < ActiveRecord::Base
  belongs_to :poll
  has_many :votes
  validates :title, presence: true, length: { minimum: 1 }
  validates_associated :votes
  scope :top, -> {
    joins('left join votes on votes.option_id = options.id').
    select('options.*, count(votes.id) as votes_count').
    group('options.id').
    order('votes_count desc')
  }
end
