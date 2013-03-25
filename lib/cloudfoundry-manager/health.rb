require 'rest_client'

module Cloudfoundry
  module Manager
    class Monitor
      def self.varz(host, port, username, password)
        RestClient.get "http://#{username}:#{password}@#{host}:#{port}/varz"
      end
    end
  end
end
