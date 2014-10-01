require_relative 'activity'

module Flowdock
  class Vote < Activity
    def initialize(vote, user)
      @vote = vote
      super(vote.option.poll, user)
    end
    def event
      "activity"
    end

    def title
      "#{@user[:name]} voted for #{@vote.option.title}"
    end
  end
end