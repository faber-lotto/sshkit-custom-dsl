module SSHKit
  module Custom
      module Runner

        require 'rake'

        class Parallel < Abstract


          def thread_pool
            @thread_pool ||= Rake::ThreadPool.new(thread_count)
          end

          def apply_block_to_bcks(&block)
            futures = to_futures(&block)
            futures.each { |f| f.value }
          end

          def thread_count
            @thread_count ||= options[:thread_count] || Rake.suggested_thread_count-1
          end

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