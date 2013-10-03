require 'aviator'

module Aviator
  class Session
    def initialize(opts=nil)
      @session_dump = opts[:session_dump] || (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
      @authenticated = opts[:session_dump] ? true : false
      @block_provided = false
    end

    def authenticate(&block)
      @authenticated = true
      @block_provided = (block ? true : false)
    end

    def authenticated?
      @authenticated
    end

    def block_provided?
      @block_provided
    end

    def dump
      @session_dump
    end

    def validate
      true
    end

    class << self
      def load(session_dump)
        new(session_dump: session_dump)
      end
    end
  end
end
