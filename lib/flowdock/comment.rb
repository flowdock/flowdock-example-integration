module Flowdock
  class Comment < Activity
    def initialize(comment, user)
      @comment = comment
      super(comment.poll, user)
    end
    def event
      "discussion"
    end
  end
end
