# frozen_string_literal: true

module Scnnr
  class Recognition
    attr_accessor :id, :objects, :state

    def initialize(attrs = {})
      @id = attrs[:id]
      @objects = (attrs[:objects] || []).map { |obj| Object.new(obj) }
      @state = attrs[:state]&.intern
    end

    def queued?
      state == :queued
    end

    def finished?
      state == :finished
    end

    def error?
      state == :error
    end
  end
end
