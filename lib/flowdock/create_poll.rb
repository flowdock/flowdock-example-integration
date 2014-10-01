require_relative 'activity'

module Flowdock
  class CreatePoll < Activity
    def event
      "activity"
    end

    def title
      "Created poll!"
    end
  end
end