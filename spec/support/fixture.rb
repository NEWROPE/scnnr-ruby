# frozen_string_literal: true

module FixtureHelper
  def fixture_path
    File.expand_path('../../fixtures', __FILE__)
  end

  def fixture(file)
    File.open(fixture_path + '/' + file)
  end
end

RSpec.configure do |c|
  c.include FixtureHelper
end
