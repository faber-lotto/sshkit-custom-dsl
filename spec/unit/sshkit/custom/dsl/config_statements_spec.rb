require 'unit_spec_helper'

module SSHKit
  module Custom
    module DSL
      describe ConfigStatements do
        subject {
          Class.new() do
            include ConfigStatements
            include Helper

            def _guard_sudo_user!(*)

            end

            def _guard_dir!(*)

            end

            def _guard_sudo_group!(*)

            end
          end.new
        }


        let(:mock_bck) {
          SSHKit.config.backend.new(SSHKit::Host.new('localhost'))
        }

        let(:hosts){['localhost', '127.0.0.1']}

        before :each do
          SSHKit::Custom::Runner::Abstract.active_backend = mock_bck
        end

        describe '.on' do
          it 'sets the backends' do
            subject.on hosts
            expect(Config::Store.backends.count).to eq(2)
          end

          it 'creates a runner' do
            subject.on hosts
            expect(Config::Store.runner).to be_kind_of SSHKit::Custom::Runner::Parallel
          end

          it 'applies a block to the runner' do
            block = ->(host){}
            runner_double = double(:runner)

            expect(subject).to receive(:_runner).and_return(runner_double)

            expect(runner_double).to receive(:apply_block_to_bcks)

            subject.on hosts, &block
          end
        end

        describe '.within' do
          it 'changes the directory' do
            dir = '1234'
            expect(subject._config_store).to receive(:add_pwd).with(dir)

            subject.within(dir)
          end

          it 'ensures the directory is set back' do
            dir = '1234'
            expect(subject._config_store).to receive(:pop_pwd)

            expect{
              subject.within(dir) do
                raise
              end
            }.to raise_error
          end

          it 'guards the block with a dir existing check' do
            dir = '1234'
            expect(subject).to receive(:_guard_dir!).with(dir)

            subject.within(dir)
          end
        end

        describe '.with' do
          it 'changes the environment' do
            env = {a: 2}
            expect(subject._config_store).to receive(:add_env).with(env)

            subject.with(env)
          end

          it 'ensures the environment is set back' do
            env = {a: 2}
            expect(subject._config_store).to receive(:pop_env)


            expect{
              subject.with(env) do
                raise
              end
            }.to raise_error
          end
        end

        describe '.as' do
          it 'changes the user and group' do
            user = 'u'
            group = 'g'

            expect(subject._config_store).to receive(:add_user_group).with(user, group)

            subject.as({user: user, group: group})
          end

          it 'ensures the user and group is set back' do
            user = 'u'
            group = 'g'
            expect(subject._config_store).to receive(:pop_user_group)

            expect{
              subject.as({user: user, group: group}) do
                raise
              end
            }.to raise_error
          end

          it 'guards the block execution with a user and group existing check' do
            user = 'u'
            group = 'g'

            expect(subject).to receive(:_guard_sudo_user!).with(user)
            expect(subject).to receive(:_guard_sudo_group!).with(user, group)

            subject.as({user: user, group: group})
          end
        end

      end
    end
  end
end
