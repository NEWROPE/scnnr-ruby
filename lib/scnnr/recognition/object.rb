# frozen_string_literal: true

module Scnnr
  class Recognition
    class Object
      def initialize(attrs = {})
        @bounding_box = attrs[:bounding_box]
        @category = attrs[:category]
        @labels = (attrs[:labels] || []).map { |label| Label.new(label) }
      end
    end
  end
end
