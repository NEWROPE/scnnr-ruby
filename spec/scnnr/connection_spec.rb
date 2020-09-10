# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Scnnr::Connection do
  before { stub_request(method, uri).to_return(body: expected_body, status: 200) }

  let(:connection) { described_class.new(uri, method, api_key, Logger.new('/dev/null')) }
  let(:uri) { URI.parse('https://dummy.scnnr.cubki.jp') }
  let(:api_key) { nil }
  let(:expected_body) { fixture('queued_recognition.json').read }

  describe '#send_request' do
    subject { connection.send_request }

    let(:method) { %i[get post].sample }

    context 'when the api_key is not set' do
      it do
        expect(subject).to be_a Net::HTTPSuccess
        expect(subject.body).to eq expected_body
        expect(WebMock).to have_requested(method, uri)
      end
    end

    context 'when the api_key is set' do
      let(:api_key) { 'dummy_key' }
      let(:requested_options) { { headers: { 'x-api-key' => api_key } } }

      it do
        expect(subject).to be_a Net::HTTPSuccess
        expect(subject.body).to eq expected_body
        expect(WebMock).to have_requested(method, uri).with(requested_options)
      end
    end

    context 'when passing block' do
      subject { connection.send_request { |request| request.content_type = requested_content_type } }

      let(:requested_content_type) { 'application/json' }

      it do
        expect(subject).to be_a Net::HTTPSuccess
        expect(subject.body).to eq expected_body
        expect(WebMock).to have_requested(method, uri).with(headers: { 'Content-Type' => requested_content_type })
      end
    end

    context 'when the response is an error' do
      let(:response_error) { described_class::RETRY_ERROR_CLASSES.sample }

      before do
        retry_count = 0

        allow_any_instance_of(described_class).to receive(:sleep)
        allow(Net::HTTP).to receive(:start) do
          retry_count += 1

          next Net::HTTPSuccess.new(nil, nil, nil) if retry_count > 1 && success_at_retry?

          raise(response_error)
        end
      end

      context 'and it succeeds after retrying' do
        let(:success_at_retry?) { true }

        it { is_expected.to be_a Net::HTTPSuccess }
      end

      context 'and it does not succeed after retrying' do
        let(:success_at_retry?) { false }

        it { expect { subject }.to raise_error(response_error) }
      end
    end
  end

  describe '#send_stream' do
    subject { connection.send_stream(image) }

    let(:method) { :post }
    let(:api_key) { 'dummy_key' }
    let(:image) { fixture('images/sample.png') }
    let(:requested_options) do
      {
        headers: {
          'x-api-key' => api_key, 'Content-Type' => 'application/octet-stream', 'Transfer-Encoding' => 'chunked'
        },
      }
    end

    it do
      # can not test checking requested body_stream with WebMock, so instead.
      expect_any_instance_of(Net::HTTP::Post).to receive(:body_stream=).with(image)
      expect(subject).to be_a Net::HTTPSuccess
      expect(subject.body).to eq expected_body
      expect(WebMock).to have_requested(method, uri).with(requested_options)
    end
  end

  describe '#send_json' do
    subject { connection.send_json(data) }

    let(:method) { :post }
    let(:api_key) { 'dummy_key' }
    let(:data) { { data: 'dummy_data' } }
    let(:requested_options) do
      {
        headers: { 'x-api-key' => api_key, 'Content-Type' => 'application/json' },
        body: data.to_json,
      }
    end

    it do
      expect(subject).to be_a Net::HTTPSuccess
      expect(subject.body).to eq expected_body
      expect(WebMock).to have_requested(method, uri).with(requested_options)
    end
  end
end
