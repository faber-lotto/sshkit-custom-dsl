module SSHKit
  module Custom
    module Runner
      # A runner which executes all commands in groups.
      #
      class Group < Abstract
        attr_writer :group_size

        # Executes all commands in batches of size :group_size
        # @yields the actual host
        def apply_block_to_bcks(&block)
          backends.each_slice(group_size).map do |group_backends|

            exec_parallel(group_backends, &block)

            do_wait

          end.flatten
        end

        # @api private
        def group_size
          @group_size ||= options[:limit] || 2
        end

        # @api private
        def exec_parallel(group, &block)
          use_runner.call(options).tap do |runner|
            runner.backends = group
            runner.apply_block_to_bcks(&block)
          end
        end

        # @api private
        def use_runner
          ->(options) { Parallel.new(options) }
        end
      end
    end
  end
end
