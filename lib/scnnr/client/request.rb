# frozen_string_literal: true

module Scnnr
  class Client
    class Request
      MAX_TIMEOUT = 25

      def initialize(options = {})
        @options = options
      end

      def request!(recognition)
        timeout = @options[:timeout] > MAX_TIMEOUT ? MAX_TIMEOUT : @options[:timeout]
        @options[:timeout] -= timeout
        recognition.request(@options)
      end

      def remain_timeout?
        @timeout.positive?
      end
    end
  end
end
