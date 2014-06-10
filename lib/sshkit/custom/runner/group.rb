module SSHKit
  module Custom
      module Runner

        class Group < Abstract
          attr_writer :group_size

          def apply_block_to_bcks(&block)
            backends.each_slice(group_size).collect do |group_backends|

              exec_parallel(group_backends, &block)

              do_wait

            end.flatten
          end


          def group_size
            @group_size ||= options[:limit] || 2
          end

          def exec_parallel(group, &block)
            use_runner.call(options).tap do |runner|
              runner.backends = group
              runner.apply_block_to_bcks(&block)
            end
          end

          def use_runner
            ->(options){ Parallel.new(options)}
          end

        end
      end
    end
end
