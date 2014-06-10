require 'unit_spec_helper'

module SSHKit
  module Custom
    module Runner
      describe Abstract do

        subject do
          Abstract.new(wait: 1)
        end

        describe '#create_runner' do
          it 'creates a group runner' do
            expect(Abstract.create_runner(in: :groups)).to be_kind_of Group
          end

          it 'creates a parallel runner' do
            expect(Abstract.create_runner(in: :parallel)).to be_kind_of Parallel
          end

          it 'creates a parallel runner as deafult' do
            expect(Abstract.create_runner({})).to be_kind_of Parallel
          end

          it 'creates a sequential runner' do
            expect(Abstract.create_runner(in: :sequence)).to be_kind_of Sequential
          end

          it 'raises an error for unknown runners' do
            expect { Abstract.create_runner(in: :abc) }.to raise_error
          end

          describe '.active_backend' do
            it 'sets the active backend' do
              subject.active_backend = :some_thing
              expect(subject.active_backend).to eq :some_thing
            end

            it 'delegates to the class method' do
              subject.active_backend = :some_thing
              expect(subject.class.active_backend).to eq :some_thing
            end
          end

          describe '.snd_cmd' do
            let(:mock_bck) do
              SSHKit.config.backend.new(SSHKit::Host.new('localhost'))
            end

            before :each do
              SSHKit::Custom::Runner::Abstract.active_backend = mock_bck
            end

            it 'sends the cmd to the active backend' do
              args=[1,2,3]
              expect(mock_bck).to receive(:execute).with(*args)
              subject.send_cmd(:execute, *args)
            end

            it 'executes a block to get the args' do
              args=[1,2,3]
              expect(mock_bck).to receive(:execute).with(*args)

              subject.send_cmd(:execute) do
                args
              end

            end

            it 'reraises an exception' do
              expect do
                subject.send_cmd(:execute) do
                  raise
                end
              end.to raise_error
            end

          end

          describe '.apply_to_bck' do
            let(:mock_bck) do
              SSHKit.config.backend.new(SSHKit::Host.new('localhost'))
            end

            it 'executes the block and yields the host' do
              block = ->(_host){}
              expect(block).to receive(:call)
              subject.apply_to_bck(mock_bck, &block)
            end

            it 'reraises an exception' do
              block = ->(_host){ raise }

              expect{ subject.apply_to_bck(mock_bck, &block) }.to raise_error
            end

          end

          describe '.do_wait' do
            it 'sleeps [wait] seconds' do

              expect do
                subject.send(:do_wait)
              end.to change{Time.now.utc}.by_at_least(1)
            end

          end

          describe '.apply_block_to_bcks' do
            it 'should be implemented by sub classes' do
              expect do
                subject.apply_block_to_bcks do

                end
              end.to raise_error
            end
          end

        end
      end
    end
  end
end
