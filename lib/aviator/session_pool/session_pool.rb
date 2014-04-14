require 'redis'

module Aviator
  class SessionPool
    mutiplier = 60 * 60
    hours = 48
    DEFAULT_EXPIRY = hours * mutiplier

    class CurrentSessionNotDefinedError < StandardError
      def initialize
        super "Current session is not defined. Make sure to call ::set_current first."
      end
    end

    class SessionNotFoundError < StandardError
      def initialize(key)
        super "There is no session with key #{ key } in the pool"
      end
    end


    REDIS_KEY_PREFIX = 'aviator.session_dumps'

    class << self

      def []=(key, session)
        store(key, session, configuration[:expiry])
      end

      def store(key, session, expiry = nil)
        session_key = build_key(key)
        redis.setex(session_key, (expiry || DEFAULT_EXPIRY).to_i, session.dump)
        session
      end

      def [](key)
        session_dump = redis.get(build_key(key))

        return nil unless session_dump

        session = Aviator::Session.load(session_dump)

        session.validate ? session : nil
      end
      alias :get :[]


      # Not thread safe! BUT good enough for
      # a single-threaded web application.
      def configure(options)
        @configuration = {expiry: DEFAULT_EXPIRY}.merge(options)

        # So that the redis configuration will
        # be reloaded on the next ::redis call
        @redis = nil
      end
      attr_reader :configuration
      alias :c :configuration


      def create(key, options = {},&block)
        config = configuration.inject({}) do |acc, (k, value)|
          acc[k] = value if k.to_s !~ /^redis/
          acc
        end

        expiry = config.delete(:expiry)
        expiry = options[:expiry] || expiry
        session = Aviator::Session.new(config)

        session.authenticate &block
        store(key, session, expiry)
        session
      end


      # WARNING: Since get_current uses a class instance variable, it will contain
      # a value between http requests whether set_current was called or not for as long
      # as it was called at least once.
      def get_current
        self.get(@current_key) || (raise CurrentSessionNotDefinedError.new)
      end


      def get_or_create(key, &block)
        # If session is invalid or does not exist, self[] will return nil
        self.get(key) || self.create(key, {},&block)
      end


      # Not thread safe! BUT good enough for
      # a single-threaded web application.
      def set_current(key)
        raise SessionNotFoundError.new(key) unless self.get(key)

        @current_key = key
      end


      private

      def build_key(key)
        "#{ REDIS_KEY_PREFIX }.#{ key }"
      end

      #allow to choose which db and password
      def redis_config
        c.inject({}) do |acc, (key, value)|
          key = key.to_s
          acc[key.to_s.gsub(/^redis_/,'').to_sym] = value if key.to_s =~ /^redis_/
          acc
        end
      end

      def redis
        @redis ||= Redis.new(redis_config)
      end

    end

  end
end
