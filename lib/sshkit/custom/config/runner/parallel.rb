module SSHKit
  module Custom
    module Config
      module Runner

        class Parallel < Abstract

          def apply_block_to_bcks(&block)
            threads = []

            backends.each do |next_backend|

              threads << Thread.new(next_backend) do |backend|
                apply_to_bck backend, &block
              end

            end

            threads.map(&:join)
          end

        end
      end
    end
  end
end