# frozen_string_literal: true

module Scnnr
  class Connection
    require 'net/http'
    require 'json'

    RETRY_LIMIT = 3
    RETRY_SLEEP_TIME = 1
    RETRY_ERROR_CLASSES = [
      Timeout::Error, Errno::EINVAL,
      Errno::ECONNRESET, EOFError,
      Net::HTTPBadResponse, Net::ProtocolError,
      Net::HTTPHeaderSyntaxError
    ].freeze

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
      with_retries do
        Net::HTTP.start(@uri.host, @uri.port, use_ssl: use_ssl?) do |http|
          @logger&.info("Started #{@method.upcase} #{@uri}")
          http.request(request)
        end
      end
    end

    private

    def with_retries
      yield
    rescue *RETRY_ERROR_CLASSES => e
      retry_count ||= 0

      if retry_count < RETRY_LIMIT
        retry_count += 1
        @logger&.info("Retrying to connect: #{@uri}, attempt: #{retry_count}")

        sleep RETRY_SLEEP_TIME
        retry
      end

      raise e.class, "#{e.message} (Endpoint: #{@method.upcase} #{@uri})"
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
