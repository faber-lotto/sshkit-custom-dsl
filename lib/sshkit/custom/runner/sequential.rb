module SSHKit
  module Custom
    module Runner
      # A runner which executes all commands in sequence.
      class Sequential < Abstract
        # Executes all commands in sequence
        # @yields the actual host
        def apply_block_to_bcks(&block)
          backends.each do |backend|
            apply_to_bck backend, &block
            do_wait
          end
        end
      end
    end
  end
end
