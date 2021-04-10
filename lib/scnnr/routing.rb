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
        query: URI.encode_www_form(@queries)
      )
    end

    private

    def path
      "/#{[self.path_prefix, @path]
        .map { |value| value.sub(%r{\A/}, '').sub(%r{/\z}, '') }
        .join('/')}"
    end

    def build_queries(params, allowed_params)
      params.delete(:timeout) unless params[:timeout]&.positive?
      params.compact.slice(*allowed_params)
    end
  end
end
