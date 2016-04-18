require 'unit_spec_helper'

module SSHKit
  module Custom
    module Runner
      describe Group do
        subject do
          Group.new(wait: 0, limit: 1)
        end

        describe '.apply_block_to_bcks' do
          let(:block) { ->(_) {} }
          let(:bck1) { SSHKit.config.backend.new(SSHKit::Host.new('localhost')) }
          let(:bck2) { SSHKit.config.backend.new(SSHKit::Host.new('127.0.0.1')) }

          before :each do
            allow(subject).to receive(:use_runner).and_return(->(options) { Sequential.new(options) })
          end

          it 'calls apply_to_bck for every backend' do
            subject.backends = [bck1, bck2]

            expect(block).to receive(:call).with(bck1.host)
            expect(block).to receive(:call).with(bck2.host)

            subject.apply_block_to_bcks(&block)
          end

          it 'groups the backends into batches' do
            subject.backends = [bck1, bck2]

            expect(subject).to receive(:exec_parallel).with([bck1])
            expect(subject).to receive(:exec_parallel).with([bck2])

            subject.apply_block_to_bcks(&block)
          end
        end

        describe '.use_runner' do
          it 'creates a parallel runner' do
            expect(subject.use_runner.call({})).to be_kind_of Parallel
          end
        end
      end
    end
  end
end
