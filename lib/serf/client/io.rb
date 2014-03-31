require 'msgpack'

module Serf
  module Client
    class IO
      include Celluloid
      include Celluloid::IO
      include Celluloid::Logger

      def initialize socket, handler
        @socket = socket
        @handler = handler
        @up = MessagePack::Unpacker.new(@socket)
        async.write
        async.read
      end

      def read
        loop do
          debug 'IO#read'
          msg = @up.read
          @handler.mailbox << msg
        end
      end

      def write
        loop do
          debug 'IO#write'
          header, param = receive
          debug "writing #{header}"

          buff = MessagePack::Buffer.new
          buff << header.to_msgpack
          if param
            buff << param.to_msgpack
          end

          @socket.write buff.to_str
        end
      end

    end
  end
end
