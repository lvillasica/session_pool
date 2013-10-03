require 'aviator'

module Aviator
  class Session
    def initialize(opts=nil)
      @session_dump = opts[:session_dump] || (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
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
