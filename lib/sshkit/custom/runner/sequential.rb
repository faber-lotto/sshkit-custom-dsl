module SSHKit
  module Custom
      module Runner
        class Sequential < Abstract
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