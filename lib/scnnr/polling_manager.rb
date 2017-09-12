# frozen_string_literal: true

module Scnnr
  class PollingManager
    MAX_TIMEOUT = 25

    attr_accessor :timeout

    def initialize(timeout)
      case timeout
      when Integer, Float::INFINITY then @timeout = timeout
      else
        raise ArgumentError, "timeout must be Integer or Float::INFINITY, but given: #{timeout}"
      end
    end

    def remain_timeout?
      self.timeout.positive?
    end

    def polling(client, recognition_id, options = {})
      loop do
        timeout = [self.timeout, MAX_TIMEOUT].min
        self.timeout -= timeout
        recognition = client.fetch(recognition_id, options.merge(timeout: timeout, polling: false))
        break recognition if recognition.finished? || !self.remain_timeout?
      end
    end
  end
end
