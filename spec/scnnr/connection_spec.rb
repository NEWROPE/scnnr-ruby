# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Scnnr::Connection do
  before { stub_request(method, uri).to_return(body: expected_body, status: 200) }

  let(:connection) { described_class.new(uri, method, api_key, logger) }
  let(:uri) { URI.parse('https://dummy.scnnr.cubki.jp') }
  let(:logger) { Logger.new(STDOUT, level: :warn) }
  let(:api_key) { nil }
  let(:expected_body) { fixture('queued_recognition.json').read }

  shared_examples_for 'request successfully' do
    it do
      is_expected.to be_a Net::HTTPSuccess
      expect(subject.body).to eq expected_body
      if requested_options.empty?
        expect(WebMock).to have_requested(method, uri)
      else
        expect(WebMock).to have_requested(method, uri).with(requested_options)
      end
    end
  end

  describe '#send_request' do
    subject { connection.send_request(&block) }

    let(:method) { %i[get post].sample }
    let(:block) { nil }

    context 'when the api_key is not set' do
      let(:requested_options) { {} }

      it_behaves_like 'request successfully'
    end

    context 'when the api_key is set' do
      let(:api_key) { 'dummy_key' }
      let(:requested_options) { { headers: { 'x-api-key' => api_key } } }

      it_behaves_like 'request successfully'
    end

    context 'when passing block' do
      let(:block) { ->(request) { request.content_type = requested_content_type } }
      let(:requested_content_type) { 'application/json' }
      let(:requested_options) do
        { headers: { 'Content-Type' => requested_content_type } }
      end

      it_behaves_like 'request successfully'
    end
  end

  describe '#send_stream' do
    subject { connection.send_stream(image) }

    # can not test checking requested body_stream with WebMock, so instead.
    before { mock.any_instance_of(Net::HTTP::Post).body_stream = image }
    let(:method) { :post }
    let(:api_key) { 'dummy_key' }
    let(:image) { fixture('images/sample.png') }
    let(:requested_content_type) { 'application/octet-stream' }
    let(:requested_options) do
      {
        headers: { 'x-api-key' => api_key, 'Content-Type' => requested_content_type, 'Transfer-Encoding' => 'chunked' },
      }
    end

    it_behaves_like 'request successfully'
  end

  describe '#send_json' do
    subject { connection.send_json(data) }

    let(:method) { :post }
    let(:api_key) { 'dummy_key' }
    let(:data) { { data: 'dummy_data' } }
    let(:requested_content_type) { 'application/json' }
    let(:requested_options) do
      {
        headers: { 'x-api-key' => api_key, 'Content-Type' => requested_content_type },
        body: data.to_json,
      }
    end

    it_behaves_like 'request successfully'
  end
end
