# frozen_string_literal: true

module Scnnr
  module Poller
    class TimeoutError < StandardError; end

    def self.poll(timeout_at, &block)
      block_value = nil
      loop do
        block_value = block.call
        break if Time.now.utc > timeout_at
        next if block_value == :re_poll

        return block_value
      end
      raise Scnnr::Poller::TimeoutError, 'Polling timed out paitently'
    end
  end
end
