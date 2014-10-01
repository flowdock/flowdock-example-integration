module Flowdock
  class Activity
    def initialize(poll, user)
      @poll = poll
      @user = user
    end

    def body
      body_str = ""
    end

    def fields
      fields = []
      for option in @poll.options.top
        fields.push({
          label: option.title,
          value: option.votes_count.to_s
        })
      end
      fields
    end

    def excerpt
      ""
    end

    def author
      email = @user['email'] || "MyEmailAddress@example.com"
      {
        name: @user['name'] || "Anonymous",
        email: email,
        avatar: avatar_url(email)
      }
    end

    def status
      color = if @poll.status == "open"
        "green"
      else
        "red"
      end
      {
        value: @poll.status,
        color: color
      }
    end

    def to_hash
      {
        author: author,
        body: body,
        event: event,
        excerpt: excerpt,
        thread_id: "example:poll:#{@poll.id}",
        thread: {
          external_url: ENV['WEB_URL'],
          fields: fields,
          status: status,
          title: @poll.title
        },
        title: title
      }
    end

    def avatar_url(email)
      id = Digest::MD5.hexdigest(email.to_s.downcase)
      "https://secure.gravatar.com/avatar/#{id}?s=120&r=pg"
    end

    def save
      for integration in FlowdockIntegration.all()
        connection.post("/activities", to_hash.merge(token: integration.token))
      end
    end

    def connection
      Faraday.new FLOWDOCK_URL do |connection|
        connection.request :json
        connection.response :json, content_type: /\bjson$/
        connection.use Faraday::Response::RaiseError
        connection.adapter Faraday.default_adapter
      end
    end
  end
end
