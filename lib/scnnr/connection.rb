# frozen_string_literal: true

module Scnnr
  class Connection
    require 'net/http'
    require 'json'

    def initialize(uri, method, api_key, logger)
      @uri = uri
      @method = method
      @api_key = api_key
      @logger = logger
    end

    def send_stream(stream)
      send_request do |req|
        req['Content-Type'] = 'application/octet-stream'
        req['Transfer-Encoding'] = 'chunked'
        req.body_stream = stream
      end
    end

    def send_json(data)
      data = data.to_json if data.is_a?(Hash)
      send_request do |req|
        req['Content-Type'] = 'application/json'
        req.body = data
      end
    end

    def send_request
      block = block_given? ? Proc.new : nil
      request = build_request(&block)
      run_request(request)
    end

    private

    def run_request(request)
      Net::HTTP.start(@uri.host, @uri.port, use_ssl: use_ssl?) do |http|
        @logger&.info("Started #{@method.upcase} #{@uri}")
        http.request(request)
      end
    end

    def use_ssl?
      @uri.scheme == 'https'
    end

    def build_request
      request =
        case @method&.intern
        when :get then Net::HTTP::Get.new(@uri.request_uri)
        when :post then Net::HTTP::Post.new(@uri.request_uri)
        else raise NotImplementedError
        end
      yield(request) if block_given?
      request['x-api-key'] = @api_key if @api_key
      request
    end
  end
end
