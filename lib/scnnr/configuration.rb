# frozen_string_literal: true

module Scnnr
  Configuration = Struct.new(:api_key, :api_version, :timeout, :logger) do
    require 'logger'

    DEFAULT_LOGGER = Logger.new(STDOUT, level: :info)

    def initialize
      super(nil, 'v1', 0, DEFAULT_LOGGER)
    end
  end
end
