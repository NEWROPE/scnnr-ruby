# frozen_string_literal: true

module Scnnr
  module Poller
    class TimeoutError < StandardError
      attr_accessor :value

      def initialize(message, value)
        super(message)
        @value = value
      end
    end

    def self.poll(timeout_at, &block)
      block_value = nil
      loop do
        block_value = block.call
        next if block_value == :re_poll
        break if Time.now.utc > timeout_at

        return block_value
      end
      raise Scnnr::Poller::TimeoutError.new('Polling timed out paitently', block_value)
    end
  end
end
