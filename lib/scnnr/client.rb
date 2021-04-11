# frozen_string_literal: true

module Scnnr
  class Client
    require 'net/http'
    require 'json'

    TASTES = %i[
      boyish casual celebrity conservative
      feminine girly gyaru harajuku
      mode natural_style
    ].freeze

    def initialize
      yield(self.config) if block_given?
    end

    def config
      @config ||= Configuration.new
    end

    def recognize_image(image, options = {})
      options = default_options.merge options
      PollingManager.start(self, options) do |opts|
        uri = construct_uri('recognitions', %i[timeout public], opts)
        response = post_file(uri, image, opts)
        Response.new(response).build_recognition
      end
    end

    def recognize_url(url, options = {})
      options = default_options.merge options
      PollingManager.start(self, options) do |opts|
        uri = construct_uri('remote/recognitions', %i[timeout force], opts)
        response = post(uri, { url: url }, opts)
        Response.new(response).build_recognition
      end
    end

    def fetch(recognition_id, options = {})
      options = default_options.merge options
      if options.delete(:polling) == false
        uri = construct_uri("recognitions/#{recognition_id}", %i[timeout], options)
        response = get(uri, options).send_request_with_retries
        return Response.new(response).build_recognition
      end

      PollingManager.new(options.delete(:timeout)).polling(self, recognition_id, options)
    end

    def coordinate(category, labels, taste = {}, options = {})
      options = default_options.merge options
      uri = construct_uri('coordinates', %i[target], options)
      payload = {
        item: { category: category, labels: labels },
        taste: TASTES.each_with_object({}) { |key, memo| memo[key] = taste[key] if taste[key] },
      }
      response = post(uri, payload, options)
      Response.new(response).build_coordinate
    end

    private

    def default_options
      self.config.to_h
    end

    def construct_uri(path, allowed_params, options = {})
      Routing.to_url(
        path, options[:api_version],
        options, allowed_params
      )
    end

    def get(uri, options = {})
      Connection.new(uri, :get, nil, options[:logger])
    end

    def post(uri, data, options = {})
      Connection.new(uri, :post, options[:api_key], options[:logger]).send_json(data)
    end

    def post_file(uri, file, options = {})
      Connection.new(uri, :post, options[:api_key], options[:logger]).send_stream(file)
    end
  end
end
