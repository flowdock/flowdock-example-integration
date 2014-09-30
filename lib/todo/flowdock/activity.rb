module Todo
  module Flowdock
    class Activity
      def initialize(data)
        @data = data
      end

      def to_hash
        {
          author: {
            name: "Mr. Smith",
            email: "MyEmailAddress@example.com",
            avatar: avatar_url("MyEmailAddress@example.com")
          },
          body: @data[:text],
          event: "discussion",
          excerpt: "Example excerpt",
          thread_id: "example:todo:thread_id",
          thread: {
            external_url: ENV['WEB_URL'],
            fields: [],
            status: {
              value: "open",
              color: "red"
            },
            title: "Example thread title"
          },
          title: "Example activity title"
        }
      end

      def avatar_url(email)
        id = Digest::MD5.hexdigest(email.to_s.downcase)
        "https://secure.gravatar.com/avatar/#{id}?s=120&r=pg"
      end

      def save(token)
        connection.post("/activities", to_hash.merge(token: token))
      end

      def connection
        @connection ||= Faraday.new FLOWDOCK_URL do |connection|
          connection.request :json
          connection.response :json, content_type: /\bjson$/
          connection.use Faraday::Response::RaiseError
          connection.adapter Faraday.default_adapter
        end
      end
    end
  end
end
