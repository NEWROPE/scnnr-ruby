# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Scnnr::Routing do
  describe '#to_url' do
    subject { described_class.to_url(path, path_prefix, params, allowed_params) }

    let(:path) { '/foo/bar.baz' }
    let(:path_prefix) { 'v1' }
    let(:params) { { timeout: 25, public: false, nil_param: nil } }
    let(:allowed_params) { %i[timeout public] }

    it { expect(subject.to_s).to eq 'https://api.scnnr.cubki.jp/v1/foo/bar.baz?timeout=25&public=false' }
  end
end
