# frozen_string_literal: true

require_relative './routing'

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
        uri = construct_uri('recognitions', [:timeout], opts)
        uri.query = [uri.query, "public=#{options[:public]}"].compact.join('&') if options[:public] == true
        response = post_connection(uri, opts).send_stream(image)
        Response.new(response).build_recognition
      end
    end

    def recognize_url(url, options = {})
      options = merge_options options
      PollingManager.start(self, options) do |opts|
        uri = construct_uri('remote/recognitions', [:timeout], opts)
        response = post_connection(uri, opts).send_json({ url: url })
        Response.new(response).build_recognition
      end
    end

    def fetch(recognition_id, options = {})
      options = merge_options options
      return request(recognition_id, options) if options.delete(:polling) == false
      PollingManager.new(options.delete(:timeout)).polling(self, recognition_id, options)
    end

    def coordinate(category, labels, tastes = {}, options = {})
      options = merge_options options
      uri = construct_uri('coordinates', [], options)
      payload = {
        item: { category: category, labels: labels },
        tastes: TASTES.each_with_object({}) { |taste, memo| memo[taste] = tastes[taste] if tastes[taste] },
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
        build_queries(options, allowed_params)
      ).to_url.to_s
    end

    def build_queries(params, allowed_params)
      {}.tap do |queries|
        (allowed_params || []).each do |param|
          case param.intern
          when :timeout then queries[:timeout] = params[:timeout] if params[:timeout]&.positive?
          else queries[param] = params[param]
          end
        end
      end
    end

    def get_connection(uri, options = {})
      Connection.new(uri, :get, nil, options[:logger])
    end

    def post_connection(uri, options = {})
      Connection.new(uri, :post, options[:api_key], options[:logger])
    end

    def request(recognition_id, options = {})
      uri = construct_uri("recognitions/#{recognition_id}", [:timeout], options)
      response = get_connection(uri, options).send_request
      Response.new(response).build_recognition
    end
  end
end
