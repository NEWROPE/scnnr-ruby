# frozen_string_literal: true

module Scnnr
  module Errors
    class Image
      class Response
        attr_accessor :status

        def initialize(attrs)
          @status = attrs['status']
        end
      end
    end
  end
end
