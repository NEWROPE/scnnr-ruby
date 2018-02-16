# frozen_string_literal: true

module Scnnr
  class Coordinate
    class Item
      attr_reader :category, :labels

      def initialize(attrs = {})
        @category = attrs['category']
        @labels = (attrs['labels'] || []).map { |label| Label.new('name' => label) }
      end

      def to_h
        { 'category' => self.category, 'labels' => self.labels.map(&:to_h) }
      end
    end
  end
end
