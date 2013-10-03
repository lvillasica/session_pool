require 'test_helper'

class Aviator::Test

  describe 'aviator/session_pool/session_pool' do

    def default_options
      {
        config_file: 'path/to/aviator.yml',
        environment: :production,
        log_file:    'path/to/aviator.log',
        redis_host:  'localhost',
        redis_port:   6379
      }
    end


    def redis
      @redis ||= Redis.new(host: default_options[:redis_host], port: default_options[:redis_port])
    end


    def session
      @session ||= Aviator::Session.new default_options
    end


    def subject
      Aviator::SessionPool
    end


    before do
      redis.flushdb

      # Reload Session mocks each time
      load 'support/aviator_session_mock.rb'

      subject.configure default_options
    end


    describe '::[]=' do

      it 'stores the session dump in redis' do
        key = 'somestring'

        subject[key] = session

        stored = redis.get(subject.send(:build_key, key))

        stored.wont_be_nil
        stored.must_equal session.dump
      end

    end # describe '::[]='


    describe '::[]' do

      it 'retrieves a previously stored session from redis' do
        key = 'somestring'

        subject[key] = session

        retrieved = subject[key]

        retrieved.class.must_equal Aviator::Session
        retrieved.dump.must_equal session.dump
      end


      it 'returns nil when a stored session is invalid' do
        key = 'somestring'

        subject[key] = session

        Aviator::Session.class_eval do
          def validate
            false
          end
        end

        subject[key].must_be_nil
      end


      it 'returns nil when the session does not exist' do
        subject['boguskey'].must_be_nil
      end

    end # describe '::[]'


    describe '::configure' do

      it 'sets the class\'s configuration' do
        subject.configure default_options

        subject.configuration.each{ |key, value| value.must_equal default_options[key] }
      end

    end # describe '::configure'

  end

end
