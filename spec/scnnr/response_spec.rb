# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Scnnr::Response do
  shared_examples 'the method can deal with error responses' do
    context 'when the error is NotFound' do
      let(:response_class) { Net::HTTPNotFound }
      let(:body) { fixture('not_found_error.json').read }

      it do
        expect { subject }.to raise_error(Scnnr::RecognitionNotFound) do |e|
          expect(e.type).to eq parsed_body['type']
          expect(e.title).to eq parsed_body['title']
          expect(e.detail).to eq parsed_body['detail']
        end
      end
    end

    context 'when the error is UnprocessableEntity' do
      let(:response_class) { Net::HTTPUnprocessableEntity }
      let(:body) { fixture('unprocessable_entity_error.json').read }

      it do
        expect { subject }.to raise_error(Scnnr::RequestFailed) do |e|
          expect(e.type).to eq parsed_body['type']
          expect(e.title).to eq parsed_body['title']
          expect(e.detail).to eq parsed_body['detail']
        end
      end
    end

    context 'when unexpected response returns' do
      let(:response_class) { Net::HTTPUnprocessableEntity }
      let(:body) { 'UnexpectedError' }
      let(:content_type) { 'application/json' }

      it do
        expect { subject }.to raise_error(Scnnr::UnexpectedError) do |e|
          expect(e.response).to eq origin_response
          expect(e.message).to eq body
        end
      end
    end
  end

  describe '#build_recognition' do
    subject { response.build_recognition }

    before do
      allow(origin_response).to receive(:body) { body }
      allow(origin_response).to receive(:content_type) { content_type }
    end

    let(:response) { described_class.new(origin_response) }
    let(:origin_response) { response_class.new(nil, nil, nil) }
    let(:parsed_body) { JSON.parse(body) }
    let(:content_type) { Scnnr::Response::SUPPORTED_CONTENT_TYPE }
    let(:response_class) { Net::HTTPSuccess }

    context 'when recognition state is queued' do
      let(:body) { fixture('queued_recognition.json').read }

      it do
        expect { subject }.not_to raise_error
        expect(subject).to be_a Scnnr::Recognition
        expect(subject).to be_queued
        expect(subject.id).to eq parsed_body['id']
        expect(subject.objects).to be_empty
      end
    end

    context 'when recognition state is finished' do
      let(:body) { fixture('finished_recognition.json').read }

      it do
        expect { subject }.not_to raise_error
        expect(subject).to be_a Scnnr::Recognition
        expect(subject).to be_finished
        expect(subject.id).to eq parsed_body['id']
        expect(subject.objects.map(&:to_h)).to match_array parsed_body['objects']
      end

      context 'without image object' do
        it do
          expect(subject.to_h).to match_array parsed_body
        end
      end

      context 'with image object' do
        let(:body) { fixture('finished_recognition_with_image.json').read }

        it do
          expect(subject.to_h).to match_array parsed_body
        end
      end
    end

    context 'when recognition state is error' do
      context 'and an `Unexpected Content Error`' do
        let(:body) { fixture('unexpected_content_error.json').read }

        it do
          expect { subject }.to raise_error(Scnnr::RequestFailed) do |e|
            expect(e.type).to eq parsed_body['error']['type']
            expect(e.title).to eq parsed_body['error']['title']
            expect(e.detail).to eq parsed_body['error']['detail']
          end
        end
      end

      context 'and a `Download Timeout Error`' do
        let(:body) { fixture('download_timeout_error.json').read }

        it do
          expect { subject }.to raise_error(Scnnr::RecognitionFailed) do |e|
            expect(e.recognition).not_to be nil
            expect(e.type).to eq parsed_body['error']['type']
            expect(e.title).to eq parsed_body['error']['title']
            expect(e.detail).to eq parsed_body['error']['detail']
          end
        end
      end

      context 'and an `Image Downloading Failed Error`' do
        let(:body) { fixture('image_downloading_failed_error.json').read }

        it do
          expect { subject }.to raise_error(Scnnr::RecognitionFailed) do |e|
            expect(e.recognition).not_to be nil
            expect(e.type).to eq parsed_body['error']['type']
            expect(e.title).to eq parsed_body['error']['title']
            expect(e.detail).to eq parsed_body['error']['detail']
            expect(e.image.response.status).to eq parsed_body['error']['image']['response']['status']
            expect(e.image.url).to eq parsed_body['error']['image']['url']
          end
        end
      end

      context 'and an `Internal Server Error`' do
        let(:body) { fixture('internal_server_error.json').read }

        it do
          expect { subject }.to raise_error(Scnnr::UnexpectedError) do |e|
            expect(e.response).to eq origin_response
            expect(e.message).to eq body
          end
        end
      end
    end

    it_behaves_like 'the method can deal with error responses'
  end

  describe '#build_coordinate' do
    subject { response.build_coordinate }

    before do
      allow(origin_response).to receive(:body) { body }
      allow(origin_response).to receive(:content_type) { content_type }
    end

    let(:response) { described_class.new(origin_response) }
    let(:origin_response) { response_class.new(nil, nil, nil) }
    let(:parsed_body) { JSON.parse(body) }
    let(:content_type) { Scnnr::Response::SUPPORTED_CONTENT_TYPE }
    let(:response_class) { Net::HTTPSuccess }

    let(:body) { fixture('coordinates.json').read }

    it do
      expect { subject }.not_to raise_error
      expect(subject).to be_a Scnnr::Coordinate
      subject.items.zip(JSON.parse(body)['items']) do |item, json|
        expect(item.category).to eq json['category']
        expect(item.labels.map(&:name)).to eq json['labels']
        expect(item.labels.map(&:score)).to all eq nil
      end
    end

    it_behaves_like 'the method can deal with error responses'
  end
end
