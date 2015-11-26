require 'spec_helper'
require 'sidekiq/fetch'

describe Sidekiq::Client do
  let(:work_class) { SidekiqHolWorkerShouldDefaultToSidekiqWorker }
  let(:queue_name) { 'some_other_queue' }
  let(:queue)      { Sidekiq::Queue.new queue_name }
  let(:fetcher)    { Sidekiq::BasicFetch.new queues: [queue_name] }

  before { Sidekiq.redis(&:flushdb) }

  describe 'client' do
    context 'with many messages' do
      let!(:init_size) { queue.size }
      let(:last_jid)   { described_class.push('queue' => queue_name, 'class' => work_class, 'args' => [9, 10]) }

      before do
        described_class.push('queue' => queue_name, 'class' => work_class, 'args' => [3, 4])
        described_class.push('queue' => queue_name, 'class' => work_class, 'args' => [5, 6])
        described_class.push('queue' => queue_name, 'class' => work_class, 'args' => [7, 8])
      end

      it 'pushes last message to the back of the queue' do
        expect(last_jid.size).to eq 24
        expect(queue.size).to eq init_size + 4
        expect(JSON.parse(fetcher.retrieve_work.job)['args']).to eq [3, 4]
      end
    end
  end

  describe 'worker' do
    let!(:init_size) { queue.size }
    let(:jid)        { work_class.perform_async 1, 2 }

    it 'pushes one message to redis' do
      expect(jid.size).to eq 24
      expect(queue.size).to eq init_size + 1
    end

    context 'with many messages' do
      let(:last_jid) { work_class.perform_async 9, 10 }

      before do
        work_class.perform_async 3, 4
        work_class.perform_async 5, 6
        work_class.perform_async 7, 8
      end

      it 'pushes last message to the back of the queue' do
        expect(last_jid.size).to eq 24
        expect(queue.size).to eq init_size + 4
        expect(JSON.parse(fetcher.retrieve_work.job)['args']).to eq [3, 4]
      end
    end
  end
end

class SidekiqHolWorkerShouldDefaultToSidekiqWorker
  include Sidekiq::Hol::Worker

  sidekiq_options queue: :some_other_queue
end
