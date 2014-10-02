module Flowdock
  class CommentPoll < Activity
    def initialize(comment, user)
      @comment = comment
      super(comment.poll, user)
    end
    def event
      "discussion"
    end

    def body
      @comment.comment
    end

    def excerpt
      body
    end

    def title
      "Commented poll"
    end
  end
end
