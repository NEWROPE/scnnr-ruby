# frozen_string_literal: true

module Scnnr
  class Routing
    API_SCHEME = URI::HTTPS
    API_HOST = 'api.scnnr.cubki.jp'

    attr_reader :path_prefix

    def initialize(path, path_prefix, queries)
      @path = path
      @path_prefix = path_prefix
      @queries = queries
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
      '/' + [self.path_prefix, @path]
        .map { |value| value.sub(%r{\A/}, '').sub(%r{/\z}, '') }
        .join('/')
    end

    private

    def query_string
      params = self.queries
      return if params.empty?
      params
        .map { |pair| pair.map { |val| URI.encode_www_form_component val }.join('=') }
        .join('&')
    end
  end
end
