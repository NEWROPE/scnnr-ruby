# frozen_string_literal: true

module Scnnr
  class Error < StandardError
    attr_accessor :detail, :title, :type

    def initialize(message, attrs = {})
      super(message)
      @detail = attrs['detail']
      @title = attrs['title']
      @type = attrs['type']
    end
  end

  class RequestFailed < Error; end

  class RecognitionFailed < Error
    attr_accessor :recognition

    def initialize(message, recognition)
      super(message, recognition.error)
      @recognition = recognition
    end
  end

  class TimeoutError < StandardError
    attr_accessor :recognition

    def initialize(message, recognition)
      super(message)
      @recognition = recognition
    end
  end

  class UnsupportedError < StandardError
    attr_accessor :response

    def initialize(response)
      super(response.body)
      @response = response
    end
  end
end
