module Serf
  module Client
    class Response < Struct.new(:header, :body); end

    module Commands
      COMMANDS = {
        handshake: [ :header ],
        members:   [ :header, :body ],
        event:     [ :header ],
        stop:      [ :header ],
        leave:     [ :header ],
        respond:   [ :header ],
        monitor:   [ :header ],
        stop:      [ :header ],
        stream:    [ :header ],
        query:     [ :header ],
        auth:      [ :header ],
      }

      def command meth
        COMMANDS[meth.to_sym]
      end
    end

    class Connection
      include Celluloid
      include Celluloid::IO
      include Celluloid::Logger
      include Commands
      include Logger

      # This is needed to pass it on
      execute_block_on_receiver :call

      Celluloid.logger = ::Serf::Client::Logger::log
      Celluloid.logger.level = ::Logger::INFO
      #finalizer :shutdown

      def initialize address, port
        info "connecting to socket #{address} on #{port}"
        connect address, port
        @io = IO.supervise(@socket, Actor.current).actors.first # avoid self
        @callbacks = Callbacks.supervise.actors.first
        @seqid = 0
        @messages = {}
        @requests = {}
        async.receive_response
      end

      def handshake
        debug 'handshake'
        send_request(:handshake, Version: 1)
      end

      def receive_response
        loop do
          # header
          header = receive
          debug "received: #{header}"

          error header unless header['Seq']
          if header["Error"].empty?
            # Keep the :receive contained here
            process_response(header) { r = receive; debug "received more: #{r}"; r }
          else
            error header["Error"]
          end
        end
      end

      # Process the response, yielding retrieves next message
      def process_response header, &block
        msgid = header["Seq"]

        h = @requests[msgid]
        raise "No request for #{header}" if not h

        cmd = h[:header]['Command']
        parts = command cmd
        debug "Processing #{cmd}"

        raise "No such command #{h}" unless parts

        # This is most likely the ACK
        if not h[:ack?]
          if parts.include? :body
            # ACK comes with a response body
            body = yield
            # Could probably clean up old things like events here, anything not a stream
          end
          h[:ack?] = true
        else
          # Alread ACKed -> should be a stream!
          raise "Cannot handle #{h}" unless ['monitor', 'stream', 'query'].include? cmd
          body = yield
        end

        resp = Response.new(header, body)
        received_response msgid, resp
        resp
      end

      def received_response msgid, resp
        debug 'connection#received_response'
        # Tell the call back actor about our new response
        @callbacks.mailbox << resp
        # Let the future we created know about the response
        @messages[msgid] = resp
      end

      def call(method, param=nil, &block)
        msgid = send_request(method, param)
        @callbacks.add msgid, block if block_given?

        future.wait_for_response msgid
        #::Celluloid::Future.new do
        #  until msg = @messages[msgid]; end
        #  msg
        #end
      end

      def wait_for_response msgid
        until msg = @messages[msgid]; sleep 0.1; end
        msg
      end

      def send_request method, param
        debug 'send_request'

        msgid = seqid
        header = { "Command" => method.to_s, "Seq" => msgid }

        # Keep a reference for our response processing
        @requests[msgid] = { header: header, ack?: false }
        # Send to the writer
        @io.mailbox << [header, param]

        msgid
      end

      def seqid
        v = @seqid
        @seqid += 1
        v
      end

      private
      def connect address, port
        @socket = Celluloid::IO::TCPSocket.new(address, port)
      end

    end
  end
end
