# frozen_string_literal: true

module Scnnr
  class Client
    class Request
      MAX_TIMEOUT = 25

      def initialize(timeout)
        @timeout = timeout.to_i
      end

      def remain_timeout?
        @timeout.positive?
      end

      def polling(client, recognition_id, options = {})
        # TODO: construct url
        while remain_timeout?
          timeout = [@timeout, MAX_TIMEOUT].min
          @timeout -= timeout
          recognition = client.fetch(recognition_id, options.merge(timeout: timeout, polling: false))
          break recognition if recognition.finished?
        end
        recognition
      end
    end
  end
end
