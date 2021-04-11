# frozen_string_literal: true

module Scnnr
  class RoutingHelper
    API_SCHEME = URI::HTTPS
    API_HOST = 'api.scnnr.cubki.jp'

    def self.to_url(path, path_prefix, params, allowed_params)
      queries = build_queries(params, allowed_params)
      API_SCHEME.build(
        host: API_HOST,
        path: path(path_prefix, path),
        query: queries.empty? ? nil : URI.encode_www_form(queries)
      )
    end

    def self.path(path_prefix, path)
      "/#{[path_prefix, path]
        .map { |value| value.sub(%r{\A/}, '').sub(%r{/\z}, '') }
        .join('/')}"
    end

    def self.cleanup_invalid_timeout(params)
      params.reject { |k, v| k == :timeout && !v.positive? }
    end

    def self.build_queries(params, allowed_params)
      queries = filter_params(params, allowed_params)
      cleanup_invalid_timeout(queries)
    end

    def self.filter_params(params, allowed_params)
      params.compact.select { |key| allowed_params.include?(key) }
    end

    private_class_method :path, :cleanup_invalid_timeout, :build_queries, :filter_params
  end
end
