require 'spec_helper'
require 'sidekiq/fetch'

describe Sidekiq::Client do
  before { Sidekiq.redis(&:flushdb) }

  describe 'client' do
    context 'with many messages' do
      let(:queue_name) { 'yuzu' }
      let!(:queue)     { Sidekiq::Queue.new queue_name }
      let!(:init_size) { queue.size }
      let(:fetcher)    { Sidekiq::BasicFetch.new queues: [queue_name] }
      let(:last_jid)   { described_class.push('queue' => queue_name, 'class' => MyWorker, 'args' => [9, 10]) }

      before do
        described_class.push('queue' => queue_name, 'class' => MyWorker, 'args' => [3, 4])
        described_class.push('queue' => queue_name, 'class' => MyWorker, 'args' => [5, 6])
        described_class.push('queue' => queue_name, 'class' => MyWorker, 'args' => [7, 8])
      end

      it 'pushes last message to the back of the queue' do
        expect(last_jid.size).to eq 24
        expect(queue.size).to eq init_size + 4
        expect(JSON.parse(fetcher.retrieve_work.job)['args']).to eq [3, 4]
      end
    end
  end
end

class MyWorker
  include Sidekiq::Worker

  sidekiq_options queue: :yuzu
end
