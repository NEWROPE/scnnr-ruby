# frozen_string_literal: true

module Scnnr
  class Recognition
    class Object
      attr_reader :bounding_box, :category, :labels

      def initialize(attrs = {})
        @bounding_box = BoundingBox.new(attrs['bounding_box'])
        @category = attrs['category']
        @labels = (attrs['labels'] || []).map { |label| Scnnr::Label.new(label) }
      end

      def to_h
        { 'bounding_box' => self.bounding_box.to_h, 'category' => self.category, 'labels' => self.labels.map(&:to_h) }
      end
    end
  end
end
