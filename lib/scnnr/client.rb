# frozen_string_literal: true

module Scnnr
  class Client
    require 'net/http'
    require 'json'

    ENDPOINT_BASE = 'https://api.scnnr.cubki.jp'

    def initialize
      yield(self.config)
    end

    def config
      @config ||= Configuration.new
    end

    def recognize_image(image, options = {})
      options = merge_options(options)
      uri = construct_uri('recognitions', options)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Post.new(uri.request_uri, {
          'Content-Type' => 'application/octet-stream', 'x-api-key' => options[:api_key],
          'Transfer-Encoding' => 'chunked'
        }).tap { |req| req.body_stream = image }
        options[:logger].info("Started POST #{uri.request_uri}")
        http.request(request)
      end
      handle_response(response, options)
    end

    def recognize_url(url, options = {})
      options = merge_options(options)
      uri = construct_uri('remote/recognitions', options)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Post.new(uri.request_uri, {
          'Content-Type' => 'application/json', 'x-api-key' => options[:api_key]
        }).tap { |req| req.body = { url: url }.to_json }
        options[:logger].info("Started POST #{uri.request_uri}")
        http.request(request)
      end
      handle_response(response, options)
    end

    def fetch(recognition_id, options = {})
      return request(recognition_id, options) if options.delete(:polling) == false
      options = merge_options(options)
      Request.new(options.delete(:timeout)).polling(self, recognition_id, options)
    end

    private

    def merge_options(options = {})
      self.config.to_h.merge(options)
    end

    def construct_uri(path, options = {})
      options = merge_options(options)
      URI.parse("#{ENDPOINT_BASE}/#{options[:api_version]}/#{path}?timeout=#{options[:timeout]}")
    end

    def request(recognition_id, options = {})
      options = merge_options(options)
      uri = construct_uri("recognitions/#{recognition_id}", options)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        options[:logger].info("Started GET #{uri.request_uri}")
        http.get(uri.request_uri)
      end
      handle_response(response, options)
    end

    def handle_response(response, options = {})
      case response
      when Net::HTTPSuccess
        recognition = Recognition.new(JSON.parse(response.body))
        handle_recognition(recognition, options)
      when Net::HTTPUnprocessableEntity
        if response.content_type == 'application/jp.cubki.scnnr.v1+json'
          raise Scnnr::RequestFailed.new('failed to reserve the recognition', JSON.parse(response.body))
        end
        raise UnsupportedError, response
      else
        raise UnsupportedError, response
      end
    end

    def handle_recognition(recognition, options = {})
      if recognition.queued? && options[:timeout].positive?
        raise Scnnr::TimeoutError.new('recognition timed out', recognition)
      end
      raise Scnnr::RecognitionFailed.new('recognition failed', recognition) if recognition.error?
      recognition
    end
  end
end
