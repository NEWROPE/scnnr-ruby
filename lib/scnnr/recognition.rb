# frozen_string_literal: true

module Scnnr
  class Recognition
    attr_accessor :id, :objects, :state, :image, :url

    def initialize(attrs = {})
      @id = attrs[:id]
      @objects = (attrs[:objects] || []).map { |obj| Object.new(obj) }
      @state = attrs[:state]
      @image = attrs[:image]
      @url = attrs[:url]
    end

    def request(options = {})
      if id
        fetch(options)
      elsif image
        send_image(image, options)
      elsif url
        send_url(recognition.url, options)
      else
        raise NotImplementedError
      end
    end

    def queued?
      state&.intern == :queued
    end

    def finished?
      state&.intern == :finished
    end

    def error?
      state&.intern == :error
    end

    private

    def fetch(options = {})
      # TODO: request to API using ID
    end

    def send_image(image, options = {})
      # TODO: request to API using image
    end

    def send_url(url, options = {})
      # TODO: request to API using url
    end
  end
end
