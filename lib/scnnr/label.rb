# frozen_string_literal: true

module Scnnr
  class Label
    attr_reader :name, :score

    def initialize(attrs = {})
      @name = attrs['name']
      @score = attrs['score']
    end

    def to_h
      { 'name' => self.name, 'score' => self.score }
    end
  end
end
