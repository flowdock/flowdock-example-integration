require_relative 'activity'

module Flowdock
  class ClosePoll < Activity
    def event
      "activity"
    end

    def title
      "Closed poll. #{winners}"
    end

    private

    def winners
      winners_str = ""
      leaders = @poll.leaders
      prefix = if leaders.length > 1
        "Winners are by tie: "
      else
        "Winner is: "
      end
      @poll.leaders.each_with_index do |option, index|
        if index == 0
          winners_str << option.title
        else
          winners_str << " and #{option.title}"
        end
      end
      prefix + winners_str
    end
  end
end