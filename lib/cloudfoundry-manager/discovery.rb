require 'json'
require 'yaml'
require 'timeout'
require 'nats/client'
require 'logger'

module Cloudfoundry
  module Manager
    class Discovery
      def initialize(opts={})
        @nats_host = opts[:nats_host] || 'localhost'
        @nats_user = opts[:nats_user] || 'nats'
        @nats_password = opts[:nats_password] || 'nats'
        @nats_port = opts[:nats_port] || NATS::DEFAULT_PORT
        @timeout = opts[:timeout] || 5
      end

      def find_all
        uri = "nats://#{@nats_user}:#{@nats_password}@#{@nats_host}:#{@nats_port}"
        @components = []

        NATS.start(:uri => uri) do
          NATS.on_error { |err| puts "Server Error: #{err}"; exit! }
          NATS.request('vcap.component.discover') do |response|
            @components.push(JSON.parse(response))
            NATS.stop
          end
        end
        sleep(@timeout)
        @components
      end

      def find(component)
        find_all unless @components
        @components.select {|c| c['type'].eql? component }
      end
    end
  end
end
