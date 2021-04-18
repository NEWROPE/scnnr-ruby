# frozen_string_literal: true

module Scnnr
  class PollingManager
    MAX_TIMEOUT_INTERVAL = 25

    def self.start(timeout_at, &block)
      block_value = block.call
      return block_value if block_value.finished?

      raise TimeoutError.new('Polling timed out paitently', block_value) unless Time.now.utc < timeout_at

      :poll
    end

    def self.poll(id, timeout_at, &block)
      block_value = nil
      Scnnr::Poller.poll(timeout_at) do
        block_value = block.call(id)
        block_value.finished? ? block_value : :re_poll
      end
    rescue Scnnr::Poller::TimeoutError
      raise Scnnr::TimeoutError.new('Polling timed out paitently', block_value)
    end

    def self.calculate_timeout(timeout_at)
      total_timeout = timeout_at - Time.now.utc
      [total_timeout - MAX_TIMEOUT_INTERVAL].min
    end

    def self.timeout_at(timeout)
      Time.now.utc + timeout
    end
  end
end
