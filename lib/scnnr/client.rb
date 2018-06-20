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
      options = merge_options options
      PollingManager.start(self, options) do |opts|
        uri = construct_uri('recognitions', %i[timeout public], opts)
        response = post_connection(uri, opts).send_stream(image)
        Response.new(response).build_recognition
      end
    end

    def recognize_url(url, options = {})
      options = merge_options options
      PollingManager.start(self, options) do |opts|
        uri = construct_uri('remote/recognitions', %i[timeout force], opts)
        response = post_connection(uri, opts).send_json({ url: url })
        Response.new(response).build_recognition
      end
    end

    def fetch(recognition_id, options = {})
      options = merge_options options
      return request(recognition_id, options) if options.delete(:polling) == false
      PollingManager.new(options.delete(:timeout)).polling(self, recognition_id, options)
    end

    def coordinate(category, labels, taste = {}, options = {})
      options = merge_options options
      uri = construct_uri('coordinates', %i[], options)
      payload = {
        item: { category: category, labels: labels },
        taste: TASTES.each_with_object({}) { |key, memo| memo[key] = taste[key] if taste[key] },
      }
      response = post_connection(uri, options).send_json(payload)
      Response.new(response).build_coordinate
    end

    private

    def merge_options(options = {})
      self.config.to_h.merge(options)
    end

    def construct_uri(path, allowed_params, options = {})
      Routing.new(
        path, options[:api_version],
        options, allowed_params
      ).to_url
    end

    def get_connection(uri, options = {})
      Connection.new(uri, :get, nil, options[:logger])
    end

    def post_connection(uri, options = {})
      Connection.new(uri, :post, options[:api_key], options[:logger])
    end

    def request(recognition_id, options = {})
      uri = construct_uri("recognitions/#{recognition_id}", %i[timeout], options)
      response = get_connection(uri, options).send_request
      Response.new(response).build_recognition
    end
  end
end
