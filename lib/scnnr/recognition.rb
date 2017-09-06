# frozen_string_literal: true

module Scnnr
  class Recognition
    attr_reader :id, :objects, :state

    def initialize(attrs = {})
      @id = attrs['id']
      @objects = (attrs['objects'] || []).map { |obj| Object.new(obj) }
      @state = attrs['state']&.intern
    end

    def queued?
      self.state == :queued
    end

    def finished?
      self.state == :finished
    end

    def error?
      self.state == :error
    end

    def to_h
      { 'id' => self.id, 'objects' => self.objects.map(&:to_h), 'state' => self.state.to_s }
    end
  end
end
