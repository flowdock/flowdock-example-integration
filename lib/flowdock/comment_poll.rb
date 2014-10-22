module Flowdock
  class CommentPoll < Activity
    def initialize(comment, user)
      @comment = comment
      super(comment.poll, user)
    end

    protected

    def event
      "discussion"
    end

    def body
      @comment.comment
    end

    def title
      "Commented poll"
    end
  end
end
