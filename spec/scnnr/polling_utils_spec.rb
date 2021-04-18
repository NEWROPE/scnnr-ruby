# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Scnnr::PollingUtils do
  let(:now) { Time.local(2000, 1, 1, 0, 0, 0) }
  let(:before_now) { now - 1 }
  let(:after_now) { now + 1 }

  let(:block) { proc { finished_task } }
  let(:unfinished_task) { Scnnr::Recognition.new('state' => 'queued') }
  let(:finished_task) { Scnnr::Recognition.new('state' => 'finished') }

  before do
    Timecop.freeze(now)
  end

  after do
    Timecop.return
  end

  it 'is now' do
    expect(Time.now.utc).to eq(now)
  end

  describe '.start' do
    subject(:result) { described_class.start(timeout_at, &block) }

    context 'when before timeout' do
      let(:timeout_at) { after_now }

      context 'and return finished task' do
        let(:block) { proc { finished_task } }

        it 'returns finished task' do
          expect(result).to eq(finished_task)
        end
      end

      context 'and return unfinished task' do
        let(:block) { proc { unfinished_task } }

        it 'returns :poll' do
          expect(result).to eq(:poll)
        end
      end
    end

    context 'when is already timeout' do
      let(:timeout_at) { before_now }

      context 'and return unfinished task' do
        let(:block) { proc { unfinished_task } }

        it 'raises TimeoutError' do
          expect { subject }.to raise_error(Scnnr::TimeoutError) do |e|
            expect(e.recognition).to eq unfinished_task
          end
        end
      end

      context 'and return finished task' do
        let(:block) { proc { finished_task } }

        it 'returns finished task' do
          expect(result).to eq finished_task
        end
      end
    end
  end

  describe '.poll' do
    subject(:result) { described_class.poll('id', timeout_at, &block) }

    context 'when before timeout' do
      let(:timeout_at) { after_now }

      context 'and return finished task' do
        let(:block) { proc { finished_task } }

        it 'return finished task' do
          expect(result).to eq(finished_task)
        end
      end

      context 'and return finished task or unfinished task' do
        let(:block) { proc { [finished_task, unfinished_task].sample } }

        it 'return :re_poll or unfinished task' do
          expect([finished_task, :re_poll]).to include(:re_poll)
        end
      end
    end

    context 'when is already timeout' do
      let(:timeout_at) { before_now }

      context 'and return unfinished task' do
        let(:block) { proc { unfinished_task } }

        it 'return unfinished task' do
          expect { result }.to raise_error(Scnnr::TimeoutError) do |e|
            expect(e.recognition).to eq(unfinished_task)
          end
        end
      end
    end
  end

  describe '.timeout_at' do
    subject(:result) { described_class.timeout_at(timeout) }

    context 'when passed timeout' do
      let(:timeout) { 100 }

      it 'return now + timeout' do
        expect(result).to eq(Time.now.utc + timeout)
      end
    end
  end
end
