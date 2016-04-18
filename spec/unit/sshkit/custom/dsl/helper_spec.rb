require 'unit_spec_helper'

module SSHKit
  module Custom
    module DSL
      describe Helper do
        subject do
          Class.new do
            include Helper
          end.new
        end

        let(:mock_bck) do
          SSHKit.config.backend.new(SSHKit::Host.new('localhost'))
        end

        before :each do
          SSHKit::Custom::Runner::Abstract.active_backend = mock_bck
        end

        describe '#LOGGING_METHODS' do
          it 'delegates all logging methods to active backend' do
            LOGGING_METHODS.each do |meth|
              expect(mock_bck).to receive(meth)
              subject.send(meth, 'hello world')
            end
          end
        end

        describe '.active_backend' do
          it 'returns the actual active backend' do
            expect(subject.active_backend).to eq(mock_bck)
          end
        end

        describe '.host' do
          it 'return the actual host' do
            expect(subject.host).to eq(mock_bck.host)
          end
        end

        describe '.Host' do
          it 'converts to a host object' do
            expect(subject.Host('localhost')).to be_kind_of SSHKit::Host
          end

          it 'does nothing with a host object' do
            lch = SSHKit::Host.new('localhost')
            expect(subject.Host(lch)).to eq(lch)
          end
        end
      end
    end
  end
end
