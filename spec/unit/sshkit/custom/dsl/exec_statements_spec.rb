require 'unit_spec_helper'

module SSHKit
  module Custom
    module DSL
      describe ExecStatements do
        subject do
          Class.new do
            include ExecStatements
            include ConfigStatements
            include Helper

            def _config_store
              self
            end

            attr_accessor :runner

          end.new
        end

        let(:mock_bck) do
          SSHKit.config.backend.new(SSHKit::Host.new('localhost'))
        end

        let(:hosts) { ['localhost', '127.0.0.1'] }

        before :each do
          SSHKit::Custom::Runner::Abstract.active_backend = mock_bck
        end

        describe '#EXEC_STATEMENTS' do
          it 'creates a method for each exec statement' do
            EXEC_STATEMENTS.each do |meth|
              expect(subject).to respond_to meth
            end
          end

          it 'delegates all calls to the runner' do
            subject.runner = double(:runner)
            args = [1, 2, 3, 4]

            EXEC_STATEMENTS.each do |meth|
              expect(subject.runner).to receive(:send_cmd).with(meth, *args)
              subject.send(meth, *args)
            end
          end
        end

        describe '._guard_sudo_user!' do
          it 'checks if a user can sudo with a specific user' do
            expect(subject).to receive(:execute).with(/if.*sudo.*-u.*deploy/m, verbosity: 0)
            subject._guard_sudo_user!('deploy')
          end
        end

        describe '._guard_sudo_group!' do
          it 'checks if a user can sudo with a specific group' do
            expect(subject).to receive(:execute).with(/if.*sudo.*-u.*deploy.*-g.*dgroup/m, verbosity: 0)
            subject._guard_sudo_group!('deploy', 'dgroup')
          end
        end

        describe '._guard_dir!' do
          it 'checks if a user can access a specific dir' do
            expect(subject).to receive(:execute).with(/if.*-d.*\/tmp/m, verbosity: 0)
            subject._guard_dir!('/tmp')
          end
        end

      end
    end
  end
end
