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

    def recognize_image(image, options = {})
      PollingManager.start(self, merge_options(options)) do |opts|
        uri = construct_uri('recognitions', opts)
        response = post_connection(uri, opts).send_stream(image)
        handle_response(response)
      end
    end

    def recognize_url(url, options = {})
      PollingManager.start(self, merge_options(options)) do |opts|
        uri = construct_uri('remote/recognitions', opts)
        response = post_connection(uri, opts).send_json({ url: url })
        handle_response(response)
      end
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
      handle_response(response)
    end

    def handle_response(response)
      response = Response.new(response)
      response.build_recognition
    end
  end
end
