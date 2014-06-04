module SSHKit
  module Runner

    class Group < Sequential
      attr_writer :group_size

      def do_it( &block)
        backends.each_slice(group_size).collect do |group_backends|

          Parallel.new(nil, nil).tap do |runner|
            runner.backends = group_backends
            runner.do_it(&block)
          end

          sleep wait_interval
        end.flatten
      end
    end
  end
end