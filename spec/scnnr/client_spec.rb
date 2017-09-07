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
  let(:logger) { Logger.new(STDOUT) }
  let(:logger_level) { :info }

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

  shared_examples_for 'a queued recognition instance is created correctly' do
    before do
      stub_request(:post, client.send(:construct_uri, path, options).to_s)
        .to_return(body: expected_body, status: 200)
    end
    let(:expected_body) { fixture('queued_recognition.json').read }
    let(:parsed_body) { JSON.parse(expected_body) }

    it do
      expect { subject }.not_to raise_error
      is_expected.to be_a Scnnr::Recognition
      is_expected.to be_queued
      expect(subject.id).to eq parsed_body['id']
      expect(subject.objects).to be_empty
    end
  end

  shared_examples_for 'a finished recognition instance is created correctly' do
    before do
      stub_request(method, client.send(:construct_uri, path, options).to_s)
        .to_return(body: expected_body, status: 200)
    end
    let(:expected_body) { fixture('finished_recognition.json').read }
    let(:parsed_body) { JSON.parse(expected_body) }

    it do
      expect { subject }.not_to raise_error
      is_expected.to be_a Scnnr::Recognition
      is_expected.to be_finished
      expect(subject.id).to eq parsed_body['id']
      expect(subject.objects.map(&:to_h)).to match_array parsed_body['objects']
    end
  end

  shared_examples_for 'a recognition timed out' do
    before do
      stub_request(method, client.send(:construct_uri, path, options).to_s)
        .to_return(body: expected_body, status: 200)
    end
    let(:expected_body) { fixture('queued_recognition.json').read }
    let(:parsed_body) { JSON.parse(expected_body) }

    it do
      begin
        expect { subject }.to raise_error Scnnr::TimeoutError
      rescue Scnnr::TimeoutError => e
        expect(e.recognition).to be_a Scnnr::Recognition
        expect(e.recognition.id).to eq parsed_body['id']
        expect(e.recognition.objects.map(&:to_h)).to match_array parsed_body['objects']
      end
    end
  end

  shared_examples_for 'a recognition failed' do
    before do
      stub_request(method, client.send(:construct_uri, path, options).to_s)
        .to_return(body: expected_body, status: 200)
    end
    let(:expected_body) { fixture('recognition_failed.json').read }
    let(:parsed_body) { JSON.parse(expected_body) }

    it do
      begin
        expect { subject }.to raise_error Scnnr::RecognitionFailed
      rescue Scnnr::RecognitionFailed => e
        expect(e.recognition).to be_a Scnnr::Recognition
        expect(e.recognition.id).to eq parsed_body['id']
        expect(e.recognition.objects.map(&:to_h)).to match_array parsed_body['objects']
      end
    end
  end

  shared_examples_for 'a request failed' do
    before do
      stub_request(method, client.send(:construct_uri, path, options).to_s).to_return(
        body: expected_body,
        headers: { 'Content-Type' => 'application/jp.cubki.scnnr.v1+json' },
        status: 422,
      )
    end
    let(:expected_body) { fixture('request_failed.json').read }
    let(:parsed_body) { JSON.parse(expected_body) }

    it do
      begin
        expect { subject }.to raise_error Scnnr::RequestFailed
      rescue Scnnr::RequestFailed => e
        expect(e.type).to eq parsed_body['type']
        expect(e.title).to eq parsed_body['title']
        expect(e.detail).to eq parsed_body['detail']
      end
    end
  end

  describe '#recognize_image' do
    subject { client.recognize_image(image, options) }

    let(:method) { :post }
    let(:path) { 'recognitions' }

    context 'when a provided image is valid' do
      let(:image) { fixture('images/sample.png') }

      context 'and timeout is 0 or nil' do
        let(:options) { {} }

        it_behaves_like 'a queued recognition instance is created correctly'
      end

      context 'and timeout is more then 0' do
        let(:options) { { timeout: rand(1..25) } }

        context 'and a recognition finishes in time' do
          it_behaves_like 'a finished recognition instance is created correctly'
        end

        context 'and a recognition does not finish in time' do
          it_behaves_like 'a recognition timed out'
        end
      end
    end

    context 'when a provided image is invalid' do
      let(:image) { nil }
      let(:options) { { timeout: rand(0..25) } }

      it_behaves_like 'a request failed'
    end
  end

  describe '#recognize_url' do
    subject { client.recognize_url(url, options) }

    let(:method) { :post }
    let(:path) { 'remote/recognitions' }

    context 'when a provided url is valid' do
      let(:url) { 'https://example.com/dummy.jpg' }

      context 'and timeout is 0 or nil' do
        let(:options) { {} }

        it_behaves_like 'a queued recognition instance is created correctly'
      end

      context 'and timeout is more then 0' do
        let(:options) { { timeout: rand(1..25) } }

        context 'and a recognition finishes in time' do
          it_behaves_like 'a finished recognition instance is created correctly'
        end
        context 'and a recognition does not finish in time' do
          it_behaves_like 'a recognition timed out'
        end
      end
    end

    context 'when a provided url is invalid' do
      let(:url) { 'https://example.com/dummy.pdf' }

      context 'and timeout is 0 or nil' do
        let(:options) { {} }

        it_behaves_like 'a queued recognition instance is created correctly'
      end

      context 'and timeout is more then 0' do
        let(:options) { { timeout: rand(1..25) } }

        context 'and a recognition finishes in time' do
          it_behaves_like 'a recognition failed'
        end

        context 'and a recognition does not finish in time' do
          it_behaves_like 'a recognition timed out'
        end
      end
    end
  end

  describe '#fetch' do
    subject { client.fetch(recognition_id, options) }

    let(:recognition_id) { '20170829/ed4c674c-7970-4e9c-9b26-1b6076b36b49' }
    let(:method) { :get }
    let(:path) { "recognitions/#{recognition_id}" }

    context 'when a reserved recognition is valid' do
      before do
        mock.proxy.any_instance_of(Scnnr::Client::Request).polling.with(client, recognition_id, is_a(Hash))
        mock.proxy(client).request.with(recognition_id, is_a(Hash))
      end

      context 'and timeout is 0 or nil' do
        let(:options) { {} }

        it_behaves_like 'a finished recognition instance is created correctly'
      end

      context 'and timeout is more then 0' do
        let(:options) { { timeout: rand(1..25) } }

        context 'and a recognition finishes in time' do
          it_behaves_like 'a finished recognition instance is created correctly'
        end
        context 'and a recognition does not finish in time' do
          it_behaves_like 'a recognition timed out'
        end
      end
    end

    context 'when a reserved recognition is invalid' do
      let(:options) { { timeout: rand(0..25) } }

      it_behaves_like 'a recognition failed'
    end
  end
end
