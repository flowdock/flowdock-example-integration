require_relative 'activity'

module Flowdock
  class UnVote < Activity
    def initialize(vote, user)
      @vote = vote
      super(vote.option.poll, user)
    end

    protected

    def event
      "activity"
    end

    def title
      "Removed vote from #{@vote.option.title}"
    end
  end
end
