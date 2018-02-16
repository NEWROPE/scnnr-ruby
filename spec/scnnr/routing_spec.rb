# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Scnnr::Routing do
  describe '#to_url' do
    subject { routing.to_url }

    let(:routing) { described_class.new path, path_prefix, queries }
    let(:path) { '/foo/bar.baz' }
    let(:path_prefix) { 'v1' }
    let(:queries) { { timeout: 25, public: false, nil_param: nil } }

    it { expect(subject.to_s).to eq 'https://api.scnnr.cubki.jp/v1/foo/bar.baz?timeout=25&public=false' }
  end
end
