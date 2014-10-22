module Flowdock
  class Activity
    def initialize(poll, user)
      @poll = poll
      @user = user
    end

    def save
      for integration in FlowdockIntegration.all()
        begin
          connection.post("/activities", to_hash.merge(token: integration.token))
        rescue Faraday::Error::ClientError => e
          puts "Flowdock activities endpoint returned error #{e.response[:status]}"
          if e.response[:status] == 410 # Flowdock returned that the pairing has been deleted
            puts "Destroying the removed integration"
            integration.destroy!
          end
        end
      end
    end

    protected

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

    def actions
      @poll.options.map { |option| action_for(option)}
    end

    def action_for(option)
      {
        "name" => "Vote #{option.title}",
        "url" => ENV['WEB_URL'] + "/#{@poll.id}/vote/#{option.id}",
        "@type" => "ViewAction"
      }
    end

    def author
      {
        name: @user.name,
        email: @user.email,
        avatar: avatar_url(@user.email)
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
        external_id: "example:poll:#{@poll.id}",
        thread: {
          external_url: ENV['WEB_URL'] + "/#{@poll.id}",
          fields: fields,
          status: status,
          title: @poll.title,
          actions: actions,
        },
        title: title
      }
    end

    def avatar_url(email)
      id = Digest::MD5.hexdigest(email.to_s.downcase)
      "https://secure.gravatar.com/avatar/#{id}?s=120&r=pg"
    end

    private

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
