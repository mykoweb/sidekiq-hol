require 'spec_helper'
require 'sidekiq/fetch'

describe Sidekiq::Hol::Client do
  let(:queue_name) { 'some_queue' }
  let(:queue)      { Sidekiq::Queue.new queue_name }
  let(:fetcher)    { Sidekiq::BasicFetch.new queues: [queue_name] }

  before { Sidekiq.redis(&:flushdb) }

  describe 'errors' do
    it 'raises ArgumentError with invalid params' do
      expect { described_class.hol_push('foo', 1) }.to raise_error ArgumentError
      expect { described_class.hol_push('foo', class: 'Foo', noargs: [1, 2]) }.to raise_error ArgumentError
      expect { described_class.hol_push('queue' => 'foo', 'class' => MyHolWorker, 'noargs' => [1, 2]) }.to raise_error ArgumentError
      expect { described_class.hol_push('queue' => 'foo', 'class' => 42, 'args' => [1, 2]) }.to raise_error ArgumentError
      expect { described_class.hol_push('queue' => 'foo', 'class' => MyHolWorker, 'args' => 1) }.to raise_error ArgumentError
    end
  end

  describe 'client' do
    let!(:init_size) { queue.size }
    let(:jid)        { described_class.hol_push('queue' => queue_name, 'class' => MyHolWorker, 'args' => [1, 2]) }

    it 'pushes one message to redis' do
      expect(jid.size).to eq 24
      expect(queue.size).to eq init_size + 1
    end

    context 'with many messages' do
      let(:last_jid) { described_class.hol_push('queue' => queue_name, 'class' => MyHolWorker, 'args' => [9, 10]) }

      before do
        described_class.hol_push('queue' => queue_name, 'class' => MyHolWorker, 'args' => [3, 4])
        described_class.hol_push('queue' => queue_name, 'class' => MyHolWorker, 'args' => [5, 6])
        described_class.hol_push('queue' => queue_name, 'class' => MyHolWorker, 'args' => [7, 8])
      end

      it 'pushes last message to the head of the queue' do
        expect(last_jid.size).to eq 24
        expect(queue.size).to eq init_size + 4
        expect(JSON.parse(fetcher.retrieve_work.job)['args']).to eq [9, 10]
      end
    end
  end

  describe 'worker' do
    let!(:init_size) { queue.size }
    let(:jid)        { MyHolWorker.perform_hol_async 1, 2 }

    it 'pushes one message to redis' do
      expect(jid.size).to eq 24
      expect(queue.size).to eq init_size + 1
    end

    context 'with many messages' do
      let(:last_jid) { MyHolWorker.perform_hol_async 9, 10 }

      before do
        MyHolWorker.perform_hol_async 3, 4
        MyHolWorker.perform_hol_async 5, 6
        MyHolWorker.perform_hol_async 7, 8
      end

      it 'pushes last message to the head of the queue' do
        expect(last_jid.size).to eq 24
        expect(queue.size).to eq init_size + 4
        expect(JSON.parse(fetcher.retrieve_work.job)['args']).to eq [9, 10]
      end
    end
  end
end

class MyHolWorker
  include Sidekiq::Hol::Worker

  sidekiq_options queue: :some_queue
end
