# frozen_string_literal: true

module Scnnr
  class Routing
    API_SCHEME = URI::HTTPS
    API_HOST = 'api.scnnr.cubki.jp'

    attr_reader :path_prefix

    def initialize(path, path_prefix, params, allowed_params)
      @path = path
      @path_prefix = path_prefix
      @queries = build_queries params, allowed_params
    end

    def to_url
      API_SCHEME.build(
        host: API_HOST,
        path: self.path,
        query: query_string
      )
    end

    def queries
      @queries.reject { |_, val| val.nil? }
    end

    def path
      "/#{[self.path_prefix, @path]
        .map { |value| value.sub(%r{\A/}, '').sub(%r{/\z}, '') }
        .join('/')}"
    end

    private

    def query_string
      params = self.queries
      return if params.empty?

      params
        .map { |pair| pair.map { |val| URI.encode_www_form_component val }.join('=') }
        .join('&')
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
  end
end
