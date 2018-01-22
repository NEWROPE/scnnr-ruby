# frozen_string_literal: true

module Scnnr
  class Recognition
    attr_reader :id, :image, :objects, :state, :error

    def initialize(attrs = {})
      @id = attrs['id']
      @image = Image.new(attrs['image']) if attrs['image']
      @objects = (attrs['objects'] || []).map { |obj| Object.new(obj) }
      @state = attrs['state']&.intern
      @error = attrs['error']
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
      hash = { 'id' => self.id, 'objects' => self.objects.map(&:to_h), 'state' => self.state.to_s }
      hash['image'] = self.image.to_h if self.image
      hash
    end
  end
end
