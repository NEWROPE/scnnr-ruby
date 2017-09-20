# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Scnnr::Client do
  let(:client) do
    described_class.new do |config|
      config.api_key = api_key
      config.api_version = api_version
      config.timeout = timeout
      config.logger = logger
      config.logger.level = logger_level
    end
  end
  let(:api_key) { 'dummy_key' }
  let(:api_version) { 'v1' }
  let(:timeout) { 0 }
  let(:logger) { Logger.new('/dev/null') }
  let(:logger_level) { :info }

  let(:mock_connection) { instance_double(Scnnr::Connection) }
  let(:mock_origin_response) { instance_double(Net::HTTPResponse) }
  let(:mock_response) { instance_double(Scnnr::Response) }

  before do
    allow(mock_origin_response).to receive(:body) { fixture('queued_recognition.json') }
    allow(mock_origin_response).to receive(:content_type) { Scnnr::Response::SUPPORTED_CONTENT_TYPE }
  end

  describe '#config' do
    subject { client.config }

    it 'can set api settings via block' do
      expect(subject.api_key).to eq api_key
      expect(subject.api_version).to eq api_version
      expect(subject.timeout).to eq timeout
      expect(subject.logger).to eq logger
      expect(subject.logger.level).to eq Logger.const_get(logger_level.upcase)
    end
  end

  describe '#recognize_image' do
    subject { client.recognize_image(image, options) }

    let(:image) { fixture('images/sample.png') }
    let(:uri) { client.send(:construct_uri, 'recognitions', options) }
    let(:options) { {} }

    it do
      expect(Scnnr::Connection).to receive(:new).with(uri, :post, api_key, logger) { mock_connection }
      expect(mock_connection).to receive(:send_stream).with(image) { mock_origin_response }
      expect(Scnnr::Response).to receive(:new).with(mock_origin_response, boolean) { mock_response }
      expect(mock_response).to receive(:build_recognition)
      subject
    end
  end

  describe '#recognize_url' do
    subject { client.recognize_url(url, options) }

    let(:url) { 'https://example.com/dummy.jpg' }
    let(:uri) { client.send(:construct_uri, 'remote/recognitions', options) }
    let(:options) { {} }

    it do
      expect(Scnnr::Connection).to receive(:new).with(uri, :post, api_key, logger) { mock_connection }
      expect(mock_connection).to receive(:send_json).with({ url: url }) { mock_origin_response }
      expect(Scnnr::Response).to receive(:new).with(mock_origin_response, boolean) { mock_response }
      expect(mock_response).to receive(:build_recognition)
      subject
    end
  end

  describe '#fetch' do
    subject { client.fetch(recognition_id, options) }

    let(:uri) { client.send(:construct_uri, "recognitions/#{recognition_id}", options) }
    let(:recognition_id) { 'dummy_id' }
    let(:options) { {} }

    it do
      expect_any_instance_of(Scnnr::PollingManager).to receive(:polling).with(client, recognition_id, Hash)
        .and_call_original
      expect(Scnnr::Connection).to receive(:new).with(uri, :get, nil, logger) { mock_connection }
      expect(mock_connection).to receive(:send_request) { mock_origin_response }
      expect(Scnnr::Response).to receive(:new).with(mock_origin_response, boolean) { mock_response }
      expect(mock_response).to receive(:build_recognition) { Scnnr::Recognition.new }
      subject
    end
  end
end
