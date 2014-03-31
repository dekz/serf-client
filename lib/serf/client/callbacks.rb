module Serf
  module Client
    class Callbacks
      include Celluloid
      include Celluloid::Logger

      execute_block_on_receiver :perform_callback

      def initialize
        @callbacks = Hash.new { |h,k| h[k] = [] }
        async.process
      end

      def add id, cb
        debug "callbacks#add with id #{id}"
        @callbacks[id] << cb
      end

      def process
        loop do
          debug 'callbacks#process!'
          resp = receive
          id = resp.header["Seq"]

          cbs = @callbacks[id]
          cbs.each { |c| async.perform_callback(resp, c) }
          debug 'callbacks#process! done'
        end
      end

      def perform_callback resp, cb
        debug 'callbacks#perform_callback'
        r = cb.call resp
        r
      end

    end
  end
end
