require 'unit_spec_helper'

module SSHKit
  module Custom
    module Config
      describe Store do

        let(:mock_bck) do
          SSHKit.config.backend.new(SSHKit::Host.new('localhost'))
        end

        let(:new_env) { { ab: :cd } }
        let(:old_env) { { ab: 123, i: 5 } }

        before :each do
          SSHKit::Custom::Runner::Abstract.active_backend = mock_bck
          Store.default_runner_opts nil
        end

        describe '.create_runner' do
          it 'creates the wanted runner' do
            opts = { in: :parallel }
            expect(Runner::Abstract).to receive(:create_runner).with(opts)
            Store.create_runner opts
          end
        end

        describe '.runner' do
          it 'returns the actual runner' do
            opts = { in: :parallel }
            Store.create_runner opts

            expect(Store.runner).not_to be_nil
          end
        end

        describe '.backends=' do
          it 'stores a list of backends' do
            Store.backends = ['127.0.0.1', 'localhost'].map { |h| SSHKit::Host.new(h) }
            expect(Store.backends.last.host.hostname).to eq('localhost')
          end
        end

        describe '.add_pwd' do
          it 'adds a directory to the stack' do
            expect { Store.add_pwd('ddd') }.to change { mock_bck.pwd.count }.by(1)
          end
        end

        describe '.pop_pwd' do
          it 'removes a directory from the stack' do
            Store.add_pwd('ddd')
            Store.add_pwd('bbb')
            Store.add_pwd('ccc')
            expect { Store.pop_pwd }.to change { mock_bck.pwd.count }.by(-1)
          end
        end

        describe '.add_env' do

          it 'adds an env to the stack' do
            expect(mock_bck.env).to eq({})
            Store.add_env(new_env)
            expect(mock_bck.env).to eq(new_env)
          end

          it 'merges the old env with the new one' do
            Store.add_env(old_env)
            Store.add_env(new_env)

            expect(mock_bck.env).to eq(old_env.merge(new_env))
          end
        end

        describe '.pop_env' do
          it 'removes an env from the stack' do
            Store.add_env(new_env)
            Store.pop_env
            expect(mock_bck.env).to eq({})
          end

          it 'restores pre existing envs' do
            Store.add_env(old_env)
            Store.add_env(new_env)

            Store.pop_env

            expect(mock_bck.env).to eq(old_env)
          end
        end

        describe '.add_user_group' do
          it 'stores an user and group' do
            Store.add_user_group('u', 'g')
            expect(mock_bck.user).to eq 'u'
            expect(mock_bck.group).to eq 'g'
          end
        end

        describe '.pop_user_group' do
          it 'restores previous an user and group' do
            Store.add_user_group('u', 'g')
            Store.add_user_group('u1', 'g1')

            expect(mock_bck.user).to eq 'u1'
            expect(mock_bck.group).to eq 'g1'

            Store.pop_user_group

            expect(mock_bck.user).to eq 'u'
            expect(mock_bck.group).to eq 'g'
          end
        end

        describe '.default_runner_opts' do
          it 'sets the default options for a runner creation' do
            Store.default_runner_opts(some: :things)

            opts = { in: :groups }
            expect(Runner::Abstract).to receive(:create_runner).with({ some: :things }.merge(opts))
            Store.create_runner opts
          end
        end
      end
    end
  end
end
