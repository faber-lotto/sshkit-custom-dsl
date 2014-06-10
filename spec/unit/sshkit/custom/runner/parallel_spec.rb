require 'unit_spec_helper'

module SSHKit
  module Custom
    module Runner
      class DummyFuture
        def initialize(host, &block)
          @host = host
          @block = block
        end

        def value
          @block.call @host
        end
      end

      describe Parallel do
        let(:thread_pool){
          double(:thread_pool).tap do |t|
            allow(t).to receive(:future) do |host, &block|
              DummyFuture.new(host, &block)
            end
          end
        }

        subject{
          Parallel.new(wait: 0)
        }

        describe '.apply_block_to_bcks' do
          it 'calls apply_to_bck for every backend' do
            allow(subject).to receive(:thread_pool).and_return(thread_pool)


            block = ->(_){}

            bck1 =  SSHKit.config.backend.new(SSHKit::Host.new('localhost'))
            bck2 =  SSHKit.config.backend.new(SSHKit::Host.new('127.0.0.1'))
            subject.backends = [bck1, bck2]

            expect(block).to receive(:call).with(bck1.host)
            expect(block).to receive(:call).with(bck2.host)

            subject.apply_block_to_bcks(&block)
          end
        end

        describe '.thread_pool' do
          it 'creates a rake thread pool' do
            expect(subject.thread_pool).to be_kind_of Rake::ThreadPool
          end
        end
      end
    end
  end
end
