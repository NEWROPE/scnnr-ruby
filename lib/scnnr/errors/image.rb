# frozen_string_literal: true

module Scnnr
  module Errors
    class Image
      attr_accessor :url

      def initialize(attrs)
        @response = attrs['response']
        @url = attrs['url']
      end

      def status
        @response['status']
      end
    end
  end
end
