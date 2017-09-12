# frozen_string_literal: true

module Scnnr
  class Response
    SUPPORTED_CONTENT_TYPE = 'application/jp.cubki.scnnr.v1+json'

    def initialize(response, async)
      raise UnsupportedError, response if response.content_type != SUPPORTED_CONTENT_TYPE
      @response = response
      @async = async
    end

    def body
      @body ||= @response.body
    end

    def parsed_body
      @parsed_body ||= JSON.parse(self.body)
    end

    def async?
      @async == true
    end

    def build_recognition
      case @response
      when Net::HTTPSuccess
        recognition = Recognition.new(self.parsed_body)
        handle_recognition(recognition)
      else
        handle_error
      end
    end

    private

    def handle_recognition(recognition)
      raise TimeoutError.new('recognition timed out', recognition) if recognition.queued? && async?
      raise RecognitionFailed.new('recognition failed', recognition) if recognition.error?
      recognition
    end

    def handle_error
      case @response
      when Net::HTTPNotFound
        raise RecognitionNotFound.new('recognition not found', self.parsed_body)
      when Net::HTTPUnprocessableEntity
        raise RequestFailed.new('failed to reserve the recognition', self.parsed_body)
      else raise UnsupportedError, @response
      end
    end
  end
end
