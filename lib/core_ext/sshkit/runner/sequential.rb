module SSHKit
  module Runner
    class Sequential < Abstract
      def apply_block_to_bcks( &block)
        backends.each do |backend|
          begin

            self.active_backend = backend
            block.call(backend.host)

          rescue Exception => e
            e2 = ExecuteError.new e
            raise e2, "Exception while executing on host #{backend}: #{e.message}"
          ensure
            self.active_backend = nil
          end
          sleep wait_interval
        end
      end
    end
  end
end