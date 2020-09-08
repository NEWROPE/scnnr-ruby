# frozen_string_literal: true

module Scnnr
  class Error < StandardError
    attr_accessor :detail, :title, :type

    def initialize(attrs)
      super(attrs['detail'])
      @detail = attrs['detail']
      @title = attrs['title']
      @type = attrs['type']
    end
  end

  class RequestFailed < Error; end

  class RecognitionNotFound < Error; end

  class RecognitionFailed < Error
    attr_accessor :recognition, :image

    def initialize(recognition)
      super(recognition.error)
      @recognition = recognition
      @image = recognition.error['image']
    end
  end

  class TimeoutError < StandardError
    attr_accessor :recognition

    def initialize(message, recognition)
      super(message)
      @recognition = recognition
    end
  end

  class UnexpectedError < StandardError
    attr_accessor :response

    def initialize(response)
      super(response.body)
      @response = response
    end
  end
end
