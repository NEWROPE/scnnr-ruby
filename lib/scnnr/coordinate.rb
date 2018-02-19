# frozen_string_literal: true

module Scnnr
  class Coordinate
    attr_reader :items

    def initialize(attrs = {})
      @items = attrs['items'].map { |item| Coordinate::Item.new(item) }
    end

    def to_h
      { 'items' => self.items.map(&:to_h) }
    end
  end
end
