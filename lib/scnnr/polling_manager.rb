# frozen_string_literal: true

module Scnnr
  class PollingManager
    MAX_TIMEOUT = 25

    attr_accessor :timeout

    def self.start(client, options, &block)
      timeout = options.delete(:timeout)
      used_timeout = [timeout, MAX_TIMEOUT].min
      extra_timeout = timeout - used_timeout

      recognition = block.call(options.merge(timeout: used_timeout))
      if recognition.queued? && extra_timeout.positive?
        new(extra_timeout).polling(client, recognition.id, options)
      else
        recognition
      end
    end

    def initialize(timeout)
      case timeout
      when Integer, Float::INFINITY then @timeout = timeout
      else
        raise ArgumentError, "timeout must be Integer or Float::INFINITY, but given: #{timeout}"
      end
    end

    def polling(client, recognition_id, options = {})
      loop do
        timeout = [self.timeout, MAX_TIMEOUT].min
        self.timeout -= timeout
        recognition = client.fetch(recognition_id, options.merge(timeout: timeout, polling: false))

        break recognition unless recognition.queued?
        raise TimeoutError.new('recognition timed out', recognition) unless self.timeout.positive?
      end
    end
  end
end
