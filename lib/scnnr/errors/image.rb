# frozen_string_literal: true

module Scnnr
  module Errors
    class Image
      attr_accessor :url, :response

      def initialize(attrs)
        @response = Response.new(attrs['response'])
        @url = attrs['url']
      end
    end
  end
end
