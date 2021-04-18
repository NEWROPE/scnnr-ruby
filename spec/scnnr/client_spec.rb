# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Scnnr::Client do
  let(:client) do
    described_class.new do |config|
      config.api_key = 'dummy_key'
      config.api_version = 'v1'
      config.timeout = 0
      config.logger = Logger.new('/dev/null')
      config.logger.level = :info
    end
  end

  let(:mock_connection) { instance_double(Scnnr::Connection) }
  let(:mock_origin_response) { instance_double(Net::HTTPResponse) }
  let(:mock_response) { instance_double(Scnnr::Response) }

  def api_uri(path)
    URI.parse "https://#{Scnnr::RoutingUtils::API_HOST}/v1#{path}"
  end

  before do
    allow(mock_origin_response).to receive(:body) { fixture('queued_recognition.json') }
    allow(mock_origin_response).to receive(:content_type).and_return(Scnnr::Response::SUPPORTED_CONTENT_TYPE)
  end

  describe '#config' do
    subject { client.config }

    let(:client) do
      described_class.new do |config|
        config.api_key = 'dummy_key'
        config.api_version = 'v1'
        config.timeout = 0
        config.logger = logger
        config.logger.level = :info
      end
    end
    let(:logger) { Logger.new('/dev/null') }

    it 'can set api settings via block' do
      expect(subject.api_key).to eq 'dummy_key'
      expect(subject.api_version).to eq 'v1'
      expect(subject.timeout).to eq 0
      expect(subject.logger).to eq logger
      expect(subject.logger.level).to eq Logger::INFO
    end
  end

  describe '#recognize_image' do
    subject { client.recognize_image(image, public: true) }

    let(:image) { fixture('images/sample.png') }
    let(:expected_recognition) { Scnnr::Recognition.new }

    it do
      expect(Scnnr::Connection)
        .to receive(:new).with(
          api_uri('/recognitions?public=true'), :post, client.config.api_key, client.config.logger
        ) { mock_connection }
      expect(mock_connection).to receive(:send_stream).with(image) { mock_origin_response }
      expect(Scnnr::Response).to receive(:new).with(mock_origin_response) { mock_response }
      expect(mock_response).to receive(:build_recognition) { expected_recognition }
      expect(subject).to eq expected_recognition
    end
  end

  describe '#recognize_url' do
    subject { client.recognize_url(url, force: true) }

    let(:url) { 'https://example.com/dummy.jpg' }
    let(:expected_recognition) { Scnnr::Recognition.new }

    it do
      expect(Scnnr::Connection)
        .to receive(:new).with(
          api_uri('/remote/recognitions?force=true'), :post, client.config.api_key, client.config.logger
        ) { mock_connection }
      expect(mock_connection).to receive(:send_json).with({ url: url }) { mock_origin_response }
      expect(Scnnr::Response).to receive(:new).with(mock_origin_response) { mock_response }
      expect(mock_response).to receive(:build_recognition) { expected_recognition }
      expect(subject).to eq(expected_recognition)
    end
  end

  describe '#fetch' do
    subject { client.fetch(recognition_id) }

    let(:recognition_id) { 'dummy_id' }
    let(:expected_recognition) { Scnnr::Recognition.new }

    it do
      expect(Scnnr::Connection)
        .to receive(:new).with(
          api_uri("/recognitions/#{recognition_id}"), :get, nil, client.config.logger
        ) { mock_connection }
      expect(mock_connection).to receive(:send_request_with_retries) { mock_origin_response }
      expect(Scnnr::Response).to receive(:new).with(mock_origin_response) { mock_response }
      expect(mock_response).to receive(:build_recognition) { expected_recognition }
      expect(subject).to eq expected_recognition
    end
  end

  describe '#coordinate' do
    subject { client.coordinate(category, labels, taste.merge(unknown: 0.4)) }

    let(:category) { 'tops' }
    let(:labels) { %w[ホワイト スカート] }
    let(:taste) { { casual: 0.3, girly: 0.7 } }

    shared_examples_for('sending an expected request and a coordinate returns successfully') do |api_path|
      expected_coordinate = nil

      it do
        expect(Scnnr::Connection)
          .to receive(:new).with(
            api_uri(api_path), :post, client.config.api_key, client.config.logger
          ) { mock_connection }
        expect(mock_connection)
          .to receive(:send_json).with(
            item: { category: category, labels: labels }, taste: taste
          ) { mock_origin_response }
        expect(Scnnr::Response).to receive(:new).with(mock_origin_response) { mock_response }
        expect(mock_response).to receive(:build_coordinate) { expected_coordinate }
        expect(subject).to eq expected_coordinate
      end
    end

    it_behaves_like 'sending an expected request and a coordinate returns successfully', '/coordinates'

    context 'when `target` option is passed' do
      subject { client.coordinate(category, labels, taste.merge(unknown: 0.4), target: 8) }

      it_behaves_like 'sending an expected request and a coordinate returns successfully', '/coordinates?target=8'
    end
  end
end
