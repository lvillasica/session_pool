require 'redis'

module Aviator
  class SessionPool

    REDIS_KEY_PREFIX = 'aviator.session_dumps'

    class << self

      def []=(key, session)
        session_key = build_key(key)

        redis.set(session_key, session.dump)
      end


      def [](key)
        session_dump = redis.get(build_key(key))

        return nil unless session_dump

        session = Aviator::Session.load(session_dump)

        session.validate ? session : nil
      end


      # Not thread safe! BUT good enough for
      # a single-threaded web application.
      def configure(options)
        @configuration = options

        # So that the redis configuration will
        # be reloaded on the next ::redis call
        @redis = nil
      end
      attr_reader :configuration
      alias :c :configuration


      private

      def build_key(key)
        "#{ REDIS_KEY_PREFIX }.#{ key }"
      end

      def redis
        @redis ||= Redis.new(host: c[:redis_host], port: c[:redis_port])
      end

    end

  end
end
