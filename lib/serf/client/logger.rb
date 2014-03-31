require 'logger'

module Serf
  module Client
    module Logger
      def log
        @logger ||= ::Logger.new $stdout
      end
      module_function :log
    end
  end
end
