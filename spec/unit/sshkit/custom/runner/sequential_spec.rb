require 'unit_spec_helper'

module SSHKit
  module Custom
    module Runner
      describe Sequential do
        subject do
          Sequential.new(wait: 0)
        end

        describe '.apply_block_to_bcks' do
          it 'calls apply_to_bck for every backend' do
            block = ->(_) {}
            bck1 =  SSHKit.config.backend.new(SSHKit::Host.new('localhost'))
            bck2 =  SSHKit.config.backend.new(SSHKit::Host.new('127.0.0.1'))
            subject.backends = [bck1, bck2]

            expect(block).to receive(:call).with(bck1.host)
            expect(block).to receive(:call).with(bck2.host)

            subject.apply_block_to_bcks(&block)
          end
        end
      end
    end
  end
end
