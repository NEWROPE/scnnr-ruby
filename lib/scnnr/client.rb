# frozen_string_literal: true

module Scnnr
  class Client
    def initialize
      yield(self.config)
    end

    def config
      @config ||= Configuration.new
    end

    def recognize_image(image, options = {})
      # TODO: request to API using image
      # return recognition instance
    end

    def recognize_url(url, options = {})
      # TODO: request to API using url
      # return recognition instance
    end

    def fetch(recognition_id, options = {})
      return request(recognition_id, options[:timeout]) if options.delete(:polling) == false
      options = self.config.to_h.merge(options)
      Request.new(options.delete(:timeout)).polling(self, recognition_id, options)
    end

    private

    def request(recognition_id, timeout)
      # TODO: request to API using ID
      # return recognition instance
    end
  end
end
