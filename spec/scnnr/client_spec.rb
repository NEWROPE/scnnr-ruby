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

  before do
    stub.any_instance_of(Net::HTTPResponse).body { fixture('queued_recognition.json') }
    stub.any_instance_of(Net::HTTPResponse).content_type { Scnnr::Response::SUPPORTED_CONTENT_TYPE }
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

    before do
      mock.proxy(Scnnr::Connection).new.with(uri, :post, is_a(String), is_a(Logger))
      mock.any_instance_of(Scnnr::Connection).send_stream.with(image) { Net::HTTPResponse.new(nil, nil, nil) }
      mock.any_instance_of(Scnnr::Response).build_recognition
    end
    it { subject }
  end

  describe '#recognize_url' do
    subject { client.recognize_url(url, options) }

    let(:url) { 'https://example.com/dummy.jpg' }
    let(:uri) { client.send(:construct_uri, 'remote/recognitions', options) }
    let(:options) { {} }

    before do
      mock.proxy(Scnnr::Connection).new.with(uri, :post, is_a(String), is_a(Logger))
      mock.any_instance_of(Scnnr::Connection).send_json.with({ url: url }) { Net::HTTPResponse.new(nil, nil, nil) }
      mock.any_instance_of(Scnnr::Response).build_recognition
    end
    it { subject }
  end

  describe '#fetch' do
    subject { client.fetch(recognition_id, options) }

    let(:uri) { client.send(:construct_uri, "recognitions/#{recognition_id}", options) }
    let(:recognition_id) { 'dummy_id' }
    let(:options) { {} }

    before do
      mock.proxy.any_instance_of(Scnnr::PollingManager).polling(client, recognition_id, is_a(Hash))
      mock.any_instance_of(Scnnr::Connection).send_request { Net::HTTPResponse.new(nil, nil, nil) }
      mock.any_instance_of(Scnnr::Response).build_recognition { Scnnr::Recognition.new }
    end
    it { subject }
  end
end
