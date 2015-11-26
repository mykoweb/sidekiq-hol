module Sidekiq
  module Hol
    module Worker
      def self.included(base)
        raise ArgumentError, "You cannot include Sidekiq::Hol::Worker in an ActiveJob: #{base.name}" if base.ancestors.any? {|c| c.name == 'ActiveJob::Base' }

        base.include(Sidekiq::Worker) unless defined? base.perform_async
        base.extend(ClassMethods)
      end

      module ClassMethods
        def perform_hol_async(*args)
          client_hol_push('class' => self, 'args' => args)
        end

        def client_hol_push(item)
          pool = Thread.current[:sidekiq_via_pool] || get_sidekiq_options['pool'] || Sidekiq.redis_pool
          Sidekiq::Hol::Client.new(pool).hol_push(item.stringify_keys)
        end
      end
    end
  end
end
