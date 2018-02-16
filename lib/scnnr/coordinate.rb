# frozen_string_literal: true

module Scnnr
  class Coordinate
    attr_reader :items

    def initialize(attrs = {})
      @items = attrs['items'].map { |item| Coordinate::Item.new(item) }
    end
  end
end
