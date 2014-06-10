module SSHKit
  module Custom
      module Runner

        class Group < Abstract
          attr_writer :group_size

          def apply_block_to_bcks(&block)
            backends.each_slice(group_size).collect do |group_backends|

              Parallel.new(options).tap do |runner|
                runner.backends = group_backends
                runner.apply_block_to_bcks(&block)
              end

              do_wait

            end.flatten
          end


          def group_size
            @group_size ||= options[:limit] || 2
          end

        end
      end
    end
end
