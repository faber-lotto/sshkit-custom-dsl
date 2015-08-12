module SSHKit
  module Custom
    module Runner
      require 'rake'

      # A runner which executes all commands in prallel (different threads).
      class Parallel < Abstract
        # @api private
        def thread_pool
          @thread_pool ||= Rake::ThreadPool.new(thread_count)
        end

        # Executes all commands parallel
        # @yields the actual host
        def apply_block_to_bcks(&block)
          futures = to_futures(&block)
          futures.each(&:value)
        end

        # @api private
        def thread_count
          @thread_count ||= options[:thread_count] || Rake.suggested_thread_count - 1
        end

        # @api private
        def to_futures(&block)
          backends.map do |b|
            thread_pool.future(b) do |fb|
              apply_to_bck fb, &block
            end
          end
        end
      end
    end
  end
end
