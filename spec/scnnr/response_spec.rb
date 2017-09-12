# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Scnnr::Response do
  describe '#build_recognition' do
    subject { response.build_recognition }

    before do
      mock.any_instance_of(Net::HTTPResponse).body { body }
      mock.any_instance_of(Net::HTTPResponse).content_type { content_type }
    end
    let(:response) { described_class.new(origin_response, async) }
    let(:origin_response) { response_class.new(nil, nil, nil) }
    let(:async) { false }
    let(:parsed_body) { JSON.parse(body) }
    let(:content_type) { Scnnr::Response::SUPPORTED_CONTENT_TYPE }

    context 'when returning successful response' do
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

        context 'with async request' do
          let(:async) { true }

          it do
            expect { subject }.to raise_error(Scnnr::TimeoutError) do |e|
              expect(e.recognition).to be_a Scnnr::Recognition
              expect(e.recognition.id).to eq parsed_body['id']
              expect(e.recognition.objects.map(&:to_h)).to match_array parsed_body['objects']
            end
          end
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
        let(:body) { fixture('recognition_failed.json').read }

        it do
          expect { subject }.to raise_error(Scnnr::RecognitionFailed) do |e|
            expect(e.recognition).to be_a Scnnr::Recognition
            expect(e.recognition.id).to eq parsed_body['id']
            expect(e.recognition.objects.map(&:to_h)).to match_array parsed_body['objects']
          end
        end
      end
    end

    context 'when returning error response' do
      context 'and the error is NotFound' do
        let(:response_class) { Net::HTTPNotFound }
        let(:body) { fixture('recognition_not_found.json').read }

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
        let(:body) { fixture('request_failed.json').read }

        it do
          expect { subject }.to raise_error(Scnnr::RequestFailed) do |e|
            expect(e.type).to eq parsed_body['type']
            expect(e.title).to eq parsed_body['title']
            expect(e.detail).to eq parsed_body['detail']
          end
        end
      end
    end

    context 'when returning unsupported response' do
      let(:response_class) { Net::HTTPUnprocessableEntity }
      let(:body) { 'UnsupportedError' }
      let(:content_type) { 'application/json' }

      it do
        expect { subject }.to raise_error(Scnnr::UnsupportedError) do |e|
          expect(e.response).to eq origin_response
          expect(e.message).to eq body
        end
      end
    end
  end
end
