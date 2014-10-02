class Poll < ActiveRecord::Base
  validates :title, presence: true, length: { minimum: 3 }
  validates :status, presence: true, length: { minimum: 4 }
  validates_uniqueness_of :title, conditions: -> { where.not(status: 'open') }
  has_many :options
  has_many :comments
  #validates_associated :options

  def has_voted?(user_id)
    options.joins(:votes).where(votes: {user_id: user_id}).exists?
  end

  def leaders
    lead_options = []
    max = 0
    for option in options.top
      if option.votes_count < max
        return lead_options
      else
        lead_options.push option
        max = option.votes_count
      end
    end
  end
end
