# frozen_string_literal: true

module Scnnr
  class Response
    SUPPORTED_CONTENT_TYPE = 'application/jp.cubki.scnnr.v1+json'

    def initialize(response)
      raise UnexpectedError, response if response.content_type != SUPPORTED_CONTENT_TYPE

      @response = response
    end

    def body
      @body ||= @response.body
    end

    def parsed_body
      @parsed_body ||= JSON.parse(self.body)
    end

    def build_recognition
      raise_error_response unless @response.is_a? Net::HTTPSuccess
      recognition = Recognition.new(self.parsed_body)
      handle_recognition(recognition)
    end

    def build_coordinate
      raise_error_response unless @response.is_a? Net::HTTPSuccess
      Coordinate.new(self.parsed_body)
    end

    private

    def handle_recognition(recognition)
      return recognition unless recognition.error?

      case recognition.error['type']
      when 'unexpected-content', 'bad-request'
        raise RequestFailed, recognition.error
      when 'download-timeout', 'invalid-image', 'download-failed'
        raise RecognitionFailed, recognition
      else raise UnexpectedError, @response
      end
    end

    def raise_error_response
      case @response
      when Net::HTTPNotFound
        raise RecognitionNotFound, self.parsed_body
      when Net::HTTPUnprocessableEntity
        raise RequestFailed, self.parsed_body
      else raise UnexpectedError, @response
      end
    end
  end
end
