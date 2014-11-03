require_relative 'activity'

module Flowdock
  class VoteChange < Activity
    def initialize(vote, previous_vote, user)
      @vote = vote
      @previous_vote = previous_vote
      super(vote.option.poll, user)
    end

    protected

    def event
      "activity"
    end

    def title
      "Changed vote from #{@previous_vote.option.title} to #{@vote.option.title}"
    end
  end
end
