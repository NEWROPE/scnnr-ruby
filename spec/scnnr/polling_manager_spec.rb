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

    shared_context 'finished recognition returns' do
      let(:recognition) { Scnnr::Recognition.new('state' => 'finished') }
    end

    shared_context 'not finished recognition returns' do
      let(:recognition) { Scnnr::Recognition.new }
    end

    before { mock(client).fetch(recognition_id, is_a(Hash)).times(times) { recognition } }

    context 'when timeout is 0' do
      let(:timeout) { 0 }

      context 'and finished recognition returns' do
        include_context 'finished recognition returns'
        let(:times) { 1 }

        it { expect { subject }.not_to change(manager, :timeout) }
      end

      context 'and not finished recognition returnes' do
        include_context 'not finished recognition returns'
        let(:times) { 1 }

        it { expect { subject }.not_to change(manager, :timeout) }
      end
    end

    context 'when timeout is greater than 0' do
      let(:timeout) { rand(1..100) }

      context 'and finished recognition returns' do
        include_context 'finished recognition returns'
        let(:times) { 1 }

        it do
          expect { subject }.to change { manager.timeout }
            .from(timeout).to([timeout - Scnnr::PollingManager::MAX_TIMEOUT, 0].max)
        end
      end

      context 'and not finished recognition returnes' do
        include_context 'not finished recognition returns'
        let(:times) { (Float(timeout) / Scnnr::PollingManager::MAX_TIMEOUT).ceil }

        it do
          expect { subject }.to change { manager.timeout }.from(timeout).to(0)
        end
      end
    end

    context 'when timeout is Float::INFINITY' do
      context 'and finished recognition returns' do
        include_context 'finished recognition returns'
        let(:timeout) { Float::INFINITY }
        let(:times) { 1 }

        it { expect { subject }.not_to change(manager, :timeout) }
      end
    end

    context 'when timeout is neither Integer nor Float::INFINITY' do
      let(:times) { 0 }
      let(:timeout) { nil }

      it { expect { subject }.to raise_error ArgumentError }
    end
  end
end
