module SSHKit
  module Runner

    class Parallel < Abstract

      def do_it( &block)
        threads = []
        backends.each do |host|
          threads << Thread.new(host) do |h|
            begin

              self.active_backend = h
              block.call(h.host)

            rescue Exception => e
              e2 = ExecuteError.new e
              raise e2, "Exception while executing on host #{h}: #{e.message}"
            ensure
              self.active_backend = nil
            end
          end
        end
        threads.map(&:join)
      end
    end
  end
end