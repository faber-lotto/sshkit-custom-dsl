module SSHKit
  module Runner

    class Group < Sequential
      attr_writer :group_size

      def apply_block_to_bcks( &block)
        backends.each_slice(group_size).collect do |group_backends|

          Parallel.new(nil, nil).tap do |runner|
            runner.backends = group_backends
            runner.apply_block_to_bcks(&block)
          end

          sleep wait_interval
        end.flatten
      end
    end
  end
end