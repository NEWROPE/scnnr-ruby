# frozen_string_literal: true

module Scnnr
  class Routing
    API_SCHEME = URI::HTTPS
    API_HOST = 'api.scnnr.cubki.jp'

    def self.to_url(path, path_prefix, params, allowed_params)
      queries = build_queries(params, allowed_params)
      API_SCHEME.build(
        host: API_HOST,
        path: self.path(path_prefix, path),
        query: URI.encode_www_form(queries)
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
      queries = self.filter_params(params, allowed_params)
      self.cleanup_invalid_timeout(queries)
    end

    def self.filter_params(params, allowed_params)
      params.compact.slice(*allowed_params)
    end

    private_class_method :path, :cleanup_invalid_timeout, :build_queries, :filter_params
  end
end
