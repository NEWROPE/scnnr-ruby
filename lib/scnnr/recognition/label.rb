# frozen_string_literal: true

module Scnnr
  class Recognition
    class Label
      def initialize(attrs = {})
        @name = attrs[:name]
        @score = attrs[:score]
      end
    end
  end
end
