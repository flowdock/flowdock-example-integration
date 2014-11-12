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

    def actions
      if @poll.status == "open"
        actions = @poll.options.map do |option|
          {
            "@type" => "UpdateAction",
            "name" => "Vote: #{option.title}",
            "image" => "https://openclipart.org/image/300px/svg_to_png/167549/Kliponious-green-tick.png",
            "target" => {
              "@type" => "EntryPoint",
              "urlTemplate" => ENV['WEB_URL'] + "/api/polls/#{@poll.id}/vote/#{option.id}",
              "httpMethod" => "POST"
            }
          }
        end
        actions.push(
          {
            "@type" => "UpdateAction",
            "name" => "Close poll",
            "target" => {
              "@type" => "EntryPoint",
              "urlTemplate" => ENV['WEB_URL'] + "/api/polls/#{@poll.id}/close",
              "httpMethod" => "POST"
            }
          }
        )
        actions
      else
        []
      end
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

    def author
      {
        name: @user.name,
        avatar: @user.image
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
        external_thread_id: "example:poll:#{@poll.id}",
        thread: {
          external_url: ENV['WEB_URL'] + "/polls/#{@poll.id}",
          fields: fields,
          status: status,
          title: @poll.title,
          actions: actions
        },
        title: title
      }
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
