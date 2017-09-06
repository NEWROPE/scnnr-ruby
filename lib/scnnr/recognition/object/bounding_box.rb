# frozen_string_literal: true

module Scnnr
  class Recognition
    class Object
      class BoundingBox
        attr_reader :bottom, :left, :right, :top

        def initialize(attrs = {})
          @bottom = attrs['bottom']
          @left = attrs['left']
          @right = attrs['right']
          @top = attrs['top']
        end

        def to_h
          { 'bottom' => self.bottom, 'left' => self.left, 'right' => self.right, 'top' => self.top }
        end
      end
    end
  end
end
