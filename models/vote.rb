class Vote < ActiveRecord::Base
  belongs_to :option
  belongs_to :user
  validate :user_id_has_not_voted

  def user_id_has_not_voted
    if Option.where(poll: option.poll).joins(:votes).where(votes: {user_id: user.id}).count > 0
      errors.add(:option, 'You have already voted in this poll')
    end
  end
end
