# frozen_string_literal: true

module Scnnr
  class Client
    require 'net/http'
    require 'json'

    ENDPOINT_BASE = 'https://api.scnnr.cubki.jp'

    def initialize
      yield(self.config) if block_given?
    end

    def config
      @config ||= Configuration.new
    end

    def recognize(endpoint, func, options = {})
      options = merge_options(options)
      timeout = options[:timeout]
      use_polling = timeout > 25
      options[:timeout] = 0 if use_polling
      uri = construct_uri(endpoint, options)
      response = func.call(uri, options)
      recognition = handle_response(response, options)
      use_polling ? fetch(recognition.id, options.merge(polling: true, timeout: timeout)) : recognition
    end

    def recognize_image(image, options = {})
      f = -> (uri, opt){ post_connection(uri, opt).send_stream(image) }
      recognize('recognitions', f, options)
    end

    def recognize_url(url, options = {})
      f = -> (uri, opt){ post_connection(uri, opt).send_json({ url: url }) }
      recognize('remote/recognitions', f, options)
    end

    def fetch(recognition_id, options = {})
      return request(recognition_id, options) if options.delete(:polling) == false
      options = merge_options(options)
      PollingManager.new(options.delete(:timeout)).polling(self, recognition_id, options)
    end

    private

    def merge_options(options = {})
      self.config.to_h.merge(options)
    end

    def construct_uri(path, options = {})
      options = merge_options(options)
      URI.parse("#{ENDPOINT_BASE}/#{options[:api_version]}/#{path}?timeout=#{options[:timeout]}")
    end

    def get_connection(uri, options = {})
      Connection.new(uri, :get, nil, options[:logger])
    end

    def post_connection(uri, options = {})
      Connection.new(uri, :post, options[:api_key], options[:logger])
    end

    def request(recognition_id, options = {})
      options = merge_options(options)
      uri = construct_uri("recognitions/#{recognition_id}", options)
      response = get_connection(uri, options).send_request
      handle_response(response, options)
    end

    def handle_response(response, options = {})
      response = Response.new(response, options[:timeout].positive?)
      response.build_recognition
    end
  end
end
