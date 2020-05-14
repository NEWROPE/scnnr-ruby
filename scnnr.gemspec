# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scnnr/version'

Gem::Specification.new do |spec|
  spec.name          = 'scnnr'
  spec.version       = Scnnr::VERSION
  spec.authors       = ['NEWROPE Co. Ltd.']
  spec.email         = ['support@newrope.biz']

  spec.summary       = spec.description
  spec.description   = 'Official #CBK scnnr client library for Ruby.'
  spec.homepage      = 'https://github.com/NEWROPE/scnnr-ruby'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.1'
end
