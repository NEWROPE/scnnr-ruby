# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Scnnr::Response do
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

    context 'when successful response returns' do
      let(:response_class) { Net::HTTPSuccess }

      context 'and recognition state is queued' do
        let(:body) { fixture('queued_recognition.json').read }

        it do
          expect { subject }.not_to raise_error
          is_expected.to be_a Scnnr::Recognition
          is_expected.to be_queued
          expect(subject.id).to eq parsed_body['id']
          expect(subject.objects).to be_empty
        end
      end

      context 'and recognition state is finished' do
        let(:body) { fixture('finished_recognition.json').read }

        it do
          expect { subject }.not_to raise_error
          is_expected.to be_a Scnnr::Recognition
          is_expected.to be_finished
          expect(subject.id).to eq parsed_body['id']
          expect(subject.objects.map(&:to_h)).to match_array parsed_body['objects']
        end
      end

      context 'and recognition state is error' do
        let(:body) { fixture('unexpected_content_error.json').read }

        it do
          expect { subject }.to raise_error(Scnnr::RequestFailed) do |e|
            expect(e.type).to eq parsed_body['error']['type']
            expect(e.title).to eq parsed_body['error']['title']
            expect(e.detail).to eq parsed_body['error']['detail']
          end
        end
      end
    end

    context 'when error response returns' do
      context 'and the error is NotFound' do
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

      context 'and the error is UnprocessableEntity' do
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
end
