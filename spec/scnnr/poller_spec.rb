# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Scnnr::Poller do
  subject(:result) { described_class.poll(timeout_at, &block) }

  let(:now) { Time.local(2000, 1, 1, 0, 0, 0) }
  let(:before_now) { now - 1 }
  let(:after_now) { now + 1 }

  let(:block) { proc { finished_task } }
  let(:finished_task) { Scnnr::Recognition.new('state' => 'finished') }
  let(:unfinished_task) { Scnnr::Recognition.new('state' => 'queued') }

  before do
    Timecop.freeze(now)
  end

  after do
    Timecop.return
  end

  describe '.poll' do
    context 'when it is before timeout' do
      let(:timeout_at) { after_now }

      context 'and it returns finished task' do
        let(:block) { proc { finished_task } }

        it 'return finished task' do
          expect(result).to eq(finished_task)
        end
      end

      context 'when it return :re_poll or finished task' do
        let(:block) { proc { [:re_poll, finished_task].sample } }

        it 'always return finished task' do
          expect(result).to be(finished_task)
        end
      end
    end

    context 'when it is already timeout' do
      let(:timeout_at) { before_now }
      let(:block) { proc { unfinished_task } }

      it 'raises TimeoutError' do
        expect { subject }.to raise_error(Scnnr::Poller::TimeoutError)
      end
    end
  end
end
