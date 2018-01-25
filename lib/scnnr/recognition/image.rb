# frozen_string_literal: true

module Scnnr
  class Recognition
    class Image
      attr_reader :url, :size

      def initialize(attrs = {})
        @url = attrs['url']
        @size = attrs['size']
      end

      def to_h
        { 'url' => self.url, 'size' => self.size }
      end
    end
  end
end
