# frozen_string_literal: true

module Scnnr
  class Routing
    API_SCHEME = URI::HTTPS
    API_HOST = 'api.scnnr.cubki.jp'

    attr_reader :path_prefix

    def initialize(path, path_prefix, params, allowed_params)
      @path = path
      @path_prefix = path_prefix
      @queries = filter_params(params, allowed_params)
    end

    def to_url
      API_SCHEME.build(
        host: API_HOST,
        path: self.path,
        query: URI.encode_www_form(@queries)
      )
    end

    private

    def path
      "/#{[self.path_prefix, @path]
        .map { |value| value.sub(%r{\A/}, '').sub(%r{/\z}, '') }
        .join('/')}"
    end

    def clean_up_timeout(params)
      params.reject { |k, v| k == :timeout && !v.positive? }
    end

    def build_queries(params, allowed_params)
      queries = self.filter_params(params, allowed_params)
      self.clean_up_timeout(queries)
    end

    def filter_params(params, allowed_params)
      params.compact.slice(*allowed_params)
    end
  end
end
