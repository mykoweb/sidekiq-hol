require 'spec_helper'

describe Sidekiq::Hol::Worker do
  before { Sidekiq.redis(&:flushdb) }

  describe 'worker' do
    context 'that includes sidekiq only' do
      subject { MyWorker }

      it { should respond_to :perform_async }
      it { should_not respond_to :perform_hol_async }
    end

    context 'that includes sidekiq and sidekiq-hol' do
      subject { MyHol2Worker }

      it { should respond_to :perform_async }
      it { should respond_to :perform_hol_async }
    end

    context 'that includes sidekiq-hol only' do
      subject { MyHolOnlyWorker }

      it { should respond_to :perform_async }
      it { should respond_to :perform_hol_async }
    end
  end
end

class MyWorker
  include Sidekiq::Worker

  sidekiq_options queue: :some_queue
end

class MyHol2Worker
  include Sidekiq::Worker
  include Sidekiq::Hol::Worker

  sidekiq_options queue: :some_queue
end

class MyHolOnlyWorker
  include Sidekiq::Hol::Worker

  sidekiq_options queue: :some_queue
end
