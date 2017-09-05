# frozen_string_literal: true

module Scnnr
  class Client
    def initialize
      yield(config)
    end

    def config
      @config ||= Configuration.new
    end

    def recognize_image(image, options = {})
      fetch(Recognition.new(image: image), config.to_h.merge(options))
    end

    def recognize_url(url, options = {})
      fetch(Recognition.new(url: url), config.to_h.merge(options))
    end

    def fetch(recognition, options = {})
      req = Request.new(config.to_h.merge(options))
      while req.remain_timeout?
        recognition = req.request!(recognition)
        break recognition if recognition.finished?
      end
      recognition
    end
  end
end
