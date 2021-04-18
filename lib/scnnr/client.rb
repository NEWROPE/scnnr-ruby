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
      recognize(options) do |opts|
        recognize_image_with_file(image, opts)
      end
    end

    def recognize_url(url, options = {})
      recognize(options) do |opts|
        recognize_image_with_url(url, opts)
      end
    end

    def fetch(recognition_id, options = {})
      options = default_options.merge options
      return get_recognition(recognition_id, options) if without_timeout?(options[:timeout])

      validate_timeout(options[:timeout])
      timeout_at = Scnnr.PollingManager.timeout_at(options[:timeout])

      recognize_poll(recognition_id, timeout_at, options)
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

    def recognize(options, &block)
      options = default_options.merge options
      return block.call(options) if without_timeout?(options[:timeout])

      validate_timeout(options[:timeout])
      timeout_at = Scnnr.PollingManager.timeout_at(options[:timeout])

      result = recognize_start(timeout_at, options) do |opts|
        block.call(opts)
      end

      return result unless result == :poll

      recognize_poll(result.id, timeout_at, options)
    end

    def recognize_start(timeout_at, options = {}, &block)
      Scnnr.PollingManager.start timeout_at do
        timeout = Scnnr.PollingManager.calculate_timeout(timeout_at)
        block.call(options.merge({ timeout: timeout }))
      end
    end

    def recognize_poll(id, timeout_at, options = {})
      Scnnr.PollingManager.poll timeout_at do
        timeout = Scnnr.PollingManager.calculate_timeout(timeout_at)
        get_recognition(id, options.merge({ timeout: timeout }))
      end
    end

    def without_timeout?(timeout)
      return true if timeout.nil? || timeout.zero?
    end

    def validate_timeout(timeout)
      return if without_timeout?(timeout)
      return if timeout.is_a?(Integer) && timeout.positive?
      return if timeout.is_a?(Float::INFINITY)

      raise ArgumentError, "timeout must be Integer or Float::INFINITY, but given: #{timeout}"
    end

    def get_recognition(recognition_id, options = {})
      uri = construct_uri("recognitions/#{recognition_id}", %i[timeout], options)
      response = get(uri, options).send_request_with_retries
      Response.new(response).build_recognition
    end

    def recognize_image_with_file(file, options = {})
      uri = construct_uri('recognitions', %i[timeout public], options)
      response = post_file(uri, file, opts)
      Response.new(response).build_recognition
    end

    def recognize_image_with_url(url, options = {})
      uri = construct_uri('remote/recognitions', %i[timeout force], options)
      response = post(uri, { url: url }, options)
      Response.new(response).build_recognition
    end

    def default_options
      self.config.to_h
    end

    def construct_uri(path, allowed_params, options = {})
      RoutingHelper.to_url(
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
