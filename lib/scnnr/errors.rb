# frozen_string_literal: true

module Scnnr
  class RequestFailed < StandardError
    attr_accessor :detail, :title, :type

    def initialize(message = nil, attrs = {})
      super(message)
      @detail = attrs['detail']
      @title = attrs['title']
      @type = attrs['type']
    end
  end

  class RecognitionFailed < StandardError
    attr_accessor :detail, :title, :type, :recognition

    def initialize(message = nil, attrs = {})
      super(message)
      @detail = attrs['detail']
      @title = attrs['title']
      @type = attrs['type']
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
