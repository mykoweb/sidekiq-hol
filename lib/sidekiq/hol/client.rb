module Sidekiq
  module Hol
    class Client < ::Sidekiq::Client

      # Sidekiq::Hol does not support bulk pushes
      def hol_push(item)
        normed = normalize_item(item)
        payload = process_single(item['class'], normed)

        if payload
          raw_hol_push([payload])
          payload['jid']
        end
      end

      class << self
        def hol_push(item)
          new.hol_push(item)
        end
      end

      private

      def raw_hol_push(payloads)
        @redis_pool.with do |conn|
          conn.multi do
            atomic_hol_push(conn, payloads)
          end
        end
      end

      # atomic_hol_push only supports asynchronous push, not scheduled
      def atomic_hol_push(conn, payloads)
        q = payloads.first['queue']
        now = Time.now.to_f
        to_push = payloads.map do |entry|
          entry['enqueued_at'.freeze] = now
          Sidekiq.dump_json(entry)
        end
        conn.sadd('queues'.freeze, q)
        conn.rpush("queue:#{q}", to_push)
      end
    end
  end
end
