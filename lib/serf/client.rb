require 'celluloid'
require 'celluloid/io'
require 'celluloid/autostart' # Autostart the default notifier
require "serf/client/version"
require "serf/client/logger"
require "serf/client/connection"
require "serf/client/callbacks"
require "serf/client/io"

module Serf
  class ClientError < StandardError; end
  module Client

    def self.connect opts
      c = ::Serf::Client::Client.new(opts)
      yield c if block_given?
      c
    end

    class Client

      def initialize opts, &block
        @address = opts[:address] || 'localhost'
        @port = opts[:port] || 7373

        @connection = Connection.supervise(@address, @port).actors.first
        @connection.handshake
      end

      def query opts, &block
        o = {}
        o['Name'] = opts[:name] if opts[:name]
        o['Payload'] = opts[:payload] if opts[:payload]
        o['Timeout'] = opts[:timeout] if opts[:timeout]
        o['FilterNodes'] = opts[:filter_nodes] if opts[:filter_nodes]
        o['FilterTags'] = opts[:filter_tags] if opts[:filter_tags]
        o['RequestAck'] = opts[:request_ack] if opts[:request_ack]

        @connection.call(:query, o, &block)
      end

      def auth key, &block
        @connection.call(:auth, {'AuthKey' => key }, &block)
      end

      def event name, payload='', coalesce=true, &block
        @connection.call(:event, {'Name' => name, 'Payload' => payload, 'Coalesce' => coalesce}, &block)
      end

      def stream type, &block
        @connection.call(:stream, {'Type' => type}, &block)
      end

      def respond id, payload, &block
        @connection.call(:respond, {'ID' => id, "Payload" => payload}, &block)
      end

      def stop seqid, &block
        @connection.call(:stop, &block)
      end

      def monitor level='DEBUG', &block
        @connection.call(:monitor, {'LogLevel' => level}, &block)
      end

      def members &block
        @connection.call(:members, &block)
      end

      def force_leave name, &block
        @connection.call(:'force-leave', {'Node' => name}, &block)
      end

      def leave &block
        @connection.call(:leave, &block)
      end

      def join; end

    end
  end
end
