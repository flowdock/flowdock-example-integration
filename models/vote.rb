class Vote < ActiveRecord::Base
  belongs_to :option
  validates :user_id, presence: true, length: { minimum: 10 }
  validate :user_id_has_not_voted

  def user_id_has_not_voted
    if Option.where(poll: option.poll).joins(:votes).where(votes: {user_id: user_id}).count > 0
      errors.add(:option, 'You have already voted in this poll')
    end
  end
end
