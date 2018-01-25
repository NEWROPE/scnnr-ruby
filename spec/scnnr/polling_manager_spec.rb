# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Scnnr::PollingManager do
  let(:manager) { described_class.new(timeout) }

  describe '.start' do
    subject(:result) { described_class.start(client, options, &block) }

    let(:timeout) { Scnnr::PollingManager::MAX_TIMEOUT * 3 }
    let(:client) { instance_double(Scnnr::Client) }
    let(:options) { { api_key: 'test', timeout: timeout, public: true } }
    let(:block) { proc { finished_recognition } }

    let(:queued_recognition) { Scnnr::Recognition.new('state' => 'queued') }
    let(:finished_recognition) { Scnnr::Recognition.new('state' => 'finished') }

    it 'passes the max timeout and other options to the block' do
      expect(block).to receive(:call).with({
        api_key: 'test', timeout: Scnnr::PollingManager::MAX_TIMEOUT, public: true
      }).and_return(finished_recognition)

      result
    end

    context 'when the block returns a finished recognition' do
      let(:block) { proc { finished_recognition } }

      it 'immediately returns the recognition' do
        expect(client).not_to receive(:fetch)
        expect(subject).to eq finished_recognition
      end
    end

    context 'when the first fetch attempt finishes' do
      let(:block) { proc { queued_recognition } }

      it 'returns the finished recognition' do
        expect(client).to receive(:fetch).with(
          queued_recognition.id, hash_including(polling: false, timeout: Scnnr::PollingManager::MAX_TIMEOUT)
        ).and_return(finished_recognition)
        expect(subject).to eq finished_recognition
      end
    end

    context 'when the timeout is exceeded' do
      let(:block) { proc { queued_recognition } }

      it 'times out with the queued recognition' do
        expect(client).to receive(:fetch).with(
          queued_recognition.id, hash_including(polling: false, timeout: Scnnr::PollingManager::MAX_TIMEOUT)
        ).exactly(2).times.and_return(queued_recognition)

        expect { subject }.to raise_error(Scnnr::TimeoutError) do |e|
          expect(e.recognition).to eq queued_recognition
        end
      end
    end
  end

  describe '#polling' do
    subject { manager.polling(client, recognition_id, options) }

    let(:client) { Scnnr::Client.new }
    let(:recognition_id) { 'dummy_id' }
    let(:options) { {} }

    context 'when timeout is 0' do
      let(:timeout) { 0 }

      context 'and finished recognition returns' do
        let(:recognition) { Scnnr::Recognition.new('state' => 'finished') }

        it do
          expect(client).to(receive(:fetch).with(recognition_id, hash_including(timeout: anything, polling: false))
            .once { recognition })
          expect { subject }.not_to change(manager, :timeout)
        end
      end

      context 'and not finished recognition returns' do
        let(:recognition) { Scnnr::Recognition.new }

        it do
          expect(client).to(receive(:fetch).with(recognition_id, hash_including(timeout: anything, polling: false))
            .once { recognition })
          expect { subject }.not_to change(manager, :timeout)
        end
      end
    end

    context 'when timeout is greater than 0' do
      let(:timeout) { rand(1..100) }

      context 'and finished recognition returns' do
        let(:recognition) { Scnnr::Recognition.new('state' => 'finished') }

        it do
          expect(client).to(receive(:fetch).with(recognition_id, hash_including(timeout: anything, polling: false))
            .once { recognition })
          expect { subject }.to change { manager.timeout }
            .from(timeout).to([timeout - Scnnr::PollingManager::MAX_TIMEOUT, 0].max)
          expect(subject).to eq recognition
        end
      end

      context 'and finished recognition fails' do
        let(:recognition) { Scnnr::Recognition.new('state' => 'error') }

        it do
          expect(client).to(receive(:fetch).with(recognition_id, hash_including(timeout: anything, polling: false))
            .once { recognition })
          expect { subject }.to change { manager.timeout }
            .from(timeout).to([timeout - Scnnr::PollingManager::MAX_TIMEOUT, 0].max)
          expect(subject).to eq recognition
        end
      end

      context 'and not finished recognition returns' do
        let(:recognition) { Scnnr::Recognition.new('state' => 'queued') }
        let(:times) { (Float(timeout) / Scnnr::PollingManager::MAX_TIMEOUT).ceil }

        it do
          expect(client).to(receive(:fetch).with(recognition_id, hash_including(timeout: anything, polling: false))
            .exactly(times).times { recognition })

          expect { subject }.to raise_error(Scnnr::TimeoutError) do |e|
            expect(e.recognition).to eq recognition
          end
        end
      end
    end

    context 'when timeout is Float::INFINITY' do
      context 'and finished recognition returns' do
        let(:recognition) { Scnnr::Recognition.new('state' => 'finished') }
        let(:timeout) { Float::INFINITY }

        it do
          expect(client).to(receive(:fetch).with(recognition_id, hash_including(timeout: anything, polling: false))
            .once { recognition })
          expect { subject }.not_to change(manager, :timeout)
        end
      end
    end

    context 'when timeout is neither Integer nor Float::INFINITY' do
      let(:recognition) { nil }
      let(:timeout) { nil }

      it do
        expect(client).to(receive(:fetch).with(recognition_id, hash_including(timeout: anything, polling: false))
          .exactly(0).times { recognition })
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end
end
