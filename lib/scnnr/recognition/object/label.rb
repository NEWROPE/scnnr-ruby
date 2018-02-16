# frozen_string_literal: true

module Scnnr
  class Recognition
    class Object
      class Label < Scnnr::Label
        def initialize(*args)
          warn "[DEPRECATION] `#{self.class.name}` is deprecated. Please use `Scnnr::Label` instead."
          super
        end
      end
    end
  end
end
