# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Scnnr::PollingManager do
  let(:manager) { described_class.new(timeout) }

  describe '#remain_timeout?' do
    subject { manager.remain_timeout? }

    context 'when timeout is 0' do
      let(:timeout) { 0 }

      it { is_expected.to be false }
    end

    context 'when timeout is greater than 0' do
      let(:timeout) { rand(1..25) }

      it { is_expected.to be true }
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
        end
      end

      context 'and not finished recognition returns' do
        let(:recognition) { Scnnr::Recognition.new }
        let(:times) { (Float(timeout) / Scnnr::PollingManager::MAX_TIMEOUT).ceil }

        it do
          expect(client).to(receive(:fetch).with(recognition_id, hash_including(timeout: anything, polling: false))
            .exactly(times).times { recognition })
          expect { subject }.to change { manager.timeout }.from(timeout).to(0)
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
