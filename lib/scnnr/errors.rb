# frozen_string_literal: true

module Scnnr
  class Error < StandardError
    attr_accessor :detail, :title, :type

    def initialize(message = nil, attrs = {})
      super(message)
      @detail = attrs['detail']
      @title = attrs['title']
      @type = attrs['type']
    end
  end

  class RequestFailed < Error; end

  class RecognitionFailed < Error
    attr_accessor :recognition

    def initialize(message = nil, attrs = {})
      super(message, attrs)
      @recognition = attrs['recognition']
    end
  end

  class TimeoutError < StandardError
    attr_accessor :recognition

    def initialize(message = nil, attrs = {})
      super(message)
      @recognition = attrs['recognition']
    end
  end
end
